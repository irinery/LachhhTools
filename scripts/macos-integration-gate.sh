#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="${1:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"

fail() {
  echo "Falha no integration gate macOS: $1"
  exit 1
}

assert_file() {
  local path="$1"
  [[ -f "${path}" ]] || fail "arquivo ausente: ${path}"
}

assert_dir_with_files() {
  local path="$1"
  [[ -d "${path}" ]] || fail "diretorio ausente: ${path}"
  find "${path}" -type f | grep -q . || fail "diretorio sem arquivos: ${path}"
}

assert_pattern() {
  local path="$1"
  local pattern="$2"
  grep -Fq "${pattern}" "${path}" || fail "padrao ausente em ${path}: ${pattern}"
}

AIR_HOME="${AIR_HOME:-${AIR_SDK_HOME:-}}"
[[ -n "${AIR_HOME}" ]] || fail "AIR_HOME/AIR_SDK_HOME nao definidos."

assert_file "${AIR_HOME}/bin/adt"
if [[ -x "${AIR_HOME}/bin/amxmlc" ]]; then
  :
elif [[ -x "${AIR_HOME}/bin/mxmlc" ]]; then
  :
else
  fail "compiler AIR nao encontrado em ${AIR_HOME}/bin"
fi

assert_file "${ROOT_DIR}/scripts/build.sh"
assert_file "${ROOT_DIR}/scripts/air-descriptor.template.xml"
assert_file "${ROOT_DIR}/platform/xSplitWidget/release/lachhhWidget.swf"
assert_dir_with_files "${ROOT_DIR}/bin/CustomAnimationExamples"

for icon_path in \
  "${ROOT_DIR}/docs/Logos/Logos16.png" \
  "${ROOT_DIR}/docs/Logos/Logos32_2.png" \
  "${ROOT_DIR}/docs/Logos/Logos36_2.png" \
  "${ROOT_DIR}/docs/Logos/Logos48_2.png" \
  "${ROOT_DIR}/docs/Logos/Logo72x72.png" \
  "${ROOT_DIR}/docs/Logos/Logo114x114.png" \
  "${ROOT_DIR}/docs/Logos/Logo128x128.png"
do
  assert_file "${icon_path}"
done

assert_pattern "${ROOT_DIR}/scripts/air-descriptor.template.xml" "__VERSION__"
assert_pattern "${ROOT_DIR}/scripts/air-descriptor.template.xml" "__APP_NAME__"
assert_pattern "${ROOT_DIR}/src/com/flashinit/ReleaseInit.as" "new UI_Updater("
assert_pattern "${ROOT_DIR}/src/com/giveawaytool/ui/UI_Updater.as" "new UI_Menu();"
assert_pattern "${ROOT_DIR}/src/com/flashinit/WidgetInWindow.as" 'aLoader.load(new URLRequest("lachhhtools_widget.swf")'
assert_pattern "${ROOT_DIR}/src/com/giveawaytool/ui/ViewMenuUISelect.as" "uiCrnt = new UI_GiveawayMenu();"
assert_pattern "${ROOT_DIR}/src/com/giveawaytool/ui/ViewMenuUISelect.as" "uiCrnt = new UI_FollowSubAlert();"
assert_pattern "${ROOT_DIR}/src/com/giveawaytool/ui/ViewMenuUISelect.as" "uiCrnt = new UI_Help();"
assert_pattern "${ROOT_DIR}/src/com/giveawaytool/ui/ViewMenuUISelect.as" "uiCrnt = new UI_PlayMovies();"

echo "Integration gate macOS concluido com sucesso."
