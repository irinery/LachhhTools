#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "${ROOT_DIR}"

required_files=(
  ".github/actions/resolve-release-version/action.yml"
  ".github/workflows/pr-validation.yml"
  ".github/workflows/build-windows.yml"
  ".github/workflows/build-macos.yml"
  ".github/workflows/release-on-merge.yml"
  "scripts/build.sh"
  "scripts/build.ps1"
  "scripts/validate-windows-assets.ps1"
  "scripts/windows-critical-smoke.ps1"
  "scripts/windows-integration-gate.ps1"
  "scripts/macos-integration-gate.sh"
)

for file_path in "${required_files[@]}"; do
  if [[ ! -f "${file_path}" ]]; then
    echo "Arquivo obrigatorio ausente: ${file_path}"
    exit 1
  fi
done

parse_yaml() {
  local yaml_path="$1"
  if command -v ruby >/dev/null 2>&1; then
    ruby -e 'require "yaml"; YAML.load_file(ARGV[0])' "${yaml_path}" >/dev/null
    return 0
  fi

  if command -v python3 >/dev/null 2>&1; then
    python3 -c 'import pathlib, sys, yaml; yaml.safe_load(pathlib.Path(sys.argv[1]).read_text())' "${yaml_path}" >/dev/null
    return 0
  fi

  echo "Nem ruby nem python3 estao disponiveis para validar YAML."
  exit 1
}

while IFS= read -r yaml_path; do
  parse_yaml "${yaml_path}"
done < <(find .github/workflows .github/actions -type f \( -name "*.yml" -o -name "*.yaml" \) | sort)

while IFS= read -r shell_path; do
  bash -n "${shell_path}"
done < <(find scripts -maxdepth 1 -type f -name "*.sh" | sort)

if command -v pwsh >/dev/null 2>&1; then
  while IFS= read -r ps_path; do
    pwsh -NoLogo -NoProfile -Command '$tokens = $null; $errors = $null; [System.Management.Automation.Language.Parser]::ParseFile($args[0], [ref]$tokens, [ref]$errors) > $null; if ($errors.Count -gt 0) { $errors | ForEach-Object { Write-Error $_.Message }; exit 1 }' "${ps_path}"
  done < <(find scripts -maxdepth 1 -type f -name "*.ps1" | sort)
else
  echo "pwsh nao encontrado; validacao sintatica de PowerShell ignorada."
fi

grep -Fq "name: PR Validation" .github/workflows/pr-validation.yml
grep -Fq 'require_semver_label: "true"' .github/workflows/pr-validation.yml
grep -Fq 'require_platform_label: "true"' .github/workflows/pr-validation.yml
grep -Fq "release_windows" .github/workflows/release-on-merge.yml
grep -Fq "release_macos" .github/workflows/release-on-merge.yml
grep -Fq "platform_label" .github/actions/resolve-release-version/action.yml
grep -Fq "semver:patch" .github/pull_request_template.md
grep -Fq "platform:windows" .github/pull_request_template.md
grep -Fq "PR -> validacao -> merge -> testes de integracao -> build/release" README.md
grep -Fq "platform:both" BUILD.md

echo "CI contract validation passed."
