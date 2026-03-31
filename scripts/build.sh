#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BIN_DIR="$ROOT_DIR/bin"
BUILD_DIR="$ROOT_DIR/build"
CERT_DIR="$BUILD_DIR/certs"
INSTALLERS_DIR="$ROOT_DIR/installers"
DESCRIPTOR_TEMPLATE="$ROOT_DIR/scripts/air-descriptor.template.xml"
DESCRIPTOR_PATH="$BIN_DIR/TwitchGiveawayTool-app.xml"
OUTPUT_SWF="$BIN_DIR/TwitchGiveawayTool.swf"
WIDGET_OUTPUT="$BIN_DIR/lachhhtools_widget.swf"
WIDGET_SOURCE="$ROOT_DIR/platform/xSplitWidget/release/lachhhWidget.swf"
CERT_PATH="$CERT_DIR/dev-certificate.p12"

MAIN_CLASS="${MAIN_CLASS:-com.flashinit.ReleaseInit}"
APP_ID="${APP_ID:-com.lachhh.twitchgiveawaytool}"
APP_NAME="${APP_NAME:-LachhhTools}"
APP_FILENAME="${APP_FILENAME:-LachhhTools}"
APP_VERSION="${APP_VERSION:-1.0.0}"
AIR_NAMESPACE_VERSION="${AIR_NAMESPACE_VERSION:-25.0}"
CERT_PASS="${CERT_PASS:-changeit}"

AIR_HOME="${AIR_HOME:-${AIR_SDK_HOME:-}}"
if [[ -z "$AIR_HOME" && -d "$ROOT_DIR/tools/air-sdk" ]]; then
  AIR_HOME="$ROOT_DIR/tools/air-sdk"
fi
if [[ -z "$AIR_HOME" ]]; then
  echo "ERROR: Defina AIR_HOME (ou AIR_SDK_HOME) apontando para o AIR SDK."
  exit 1
fi

if [[ -x "$AIR_HOME/bin/amxmlc" ]]; then
  COMPILER="$AIR_HOME/bin/amxmlc"
elif [[ -x "$AIR_HOME/bin/mxmlc" ]]; then
  COMPILER="$AIR_HOME/bin/mxmlc"
else
  echo "ERROR: Não encontrei amxmlc/mxmlc em $AIR_HOME/bin."
  exit 1
fi

ADT="$AIR_HOME/bin/adt"
if [[ ! -x "$ADT" ]]; then
  echo "ERROR: Não encontrei adt em $AIR_HOME/bin."
  exit 1
fi

PACKAGE_TARGET="${PACKAGE_TARGET:-auto}"
if [[ "$PACKAGE_TARGET" == "auto" ]]; then
  case "$(uname -s)" in
    Darwin) PACKAGE_TARGET="bundle" ;;
    *) PACKAGE_TARGET="native" ;;
  esac
fi

mkdir -p "$BIN_DIR" "$BUILD_DIR" "$CERT_DIR" "$INSTALLERS_DIR"

if [[ ! -f "$WIDGET_OUTPUT" && -f "$WIDGET_SOURCE" ]]; then
  cp "$WIDGET_SOURCE" "$WIDGET_OUTPUT"
fi
if [[ ! -f "$WIDGET_OUTPUT" ]]; then
  echo "ERROR: Arquivo do widget não encontrado: $WIDGET_OUTPUT"
  echo "       Esperado também em: $WIDGET_SOURCE"
  exit 1
fi

mkdir -p "$BIN_DIR/icons"
cp "$ROOT_DIR/docs/Logos/Logos16.png" "$BIN_DIR/icons/Logos16.png"
cp "$ROOT_DIR/docs/Logos/Logos32_2.png" "$BIN_DIR/icons/Logos32_2.png"
cp "$ROOT_DIR/docs/Logos/Logos36_2.png" "$BIN_DIR/icons/Logos36_2.png"
cp "$ROOT_DIR/docs/Logos/Logos48_2.png" "$BIN_DIR/icons/Logos48_2.png"
cp "$ROOT_DIR/docs/Logos/Logo72x72.png" "$BIN_DIR/icons/Logo72x72.png"
cp "$ROOT_DIR/docs/Logos/Logo114x114.png" "$BIN_DIR/icons/Logo114x114.png"
cp "$ROOT_DIR/docs/Logos/Logo128x128.png" "$BIN_DIR/icons/Logo128x128.png"

sed \
  -e "s/__AIR_NAMESPACE_VERSION__/$AIR_NAMESPACE_VERSION/g" \
  -e "s/__APP_ID__/$APP_ID/g" \
  -e "s/__VERSION__/$APP_VERSION/g" \
  -e "s/__FILENAME__/$APP_FILENAME/g" \
  -e "s/__APP_NAME__/$APP_NAME/g" \
  "$DESCRIPTOR_TEMPLATE" > "$DESCRIPTOR_PATH"

echo "Compilando SWF..."
"$COMPILER" \
  +configname=air \
  -source-path+="$ROOT_DIR/src" \
  -library-path+="$ROOT_DIR/lib" \
  -library-path+="$ROOT_DIR/LachhhAds.swc" \
  -output "$OUTPUT_SWF" \
  -target-player=25.0 \
  -default-size=1280,720 \
  -default-frame-rate=60 \
  -static-link-runtime-shared-libraries=true \
  "$ROOT_DIR/src/${MAIN_CLASS//.//}.as"

if [[ ! -f "$CERT_PATH" ]]; then
  echo "Gerando certificado de desenvolvimento local..."
  "$ADT" -certificate -cn "LachhhTools Dev" 2048-RSA "$CERT_PATH" "$CERT_PASS"
fi

case "$PACKAGE_TARGET" in
  bundle)
    PACKAGE_OUTPUT="$INSTALLERS_DIR/LachhhTools.app"
    ;;
  native)
    if [[ "${OS:-}" == "Windows_NT" ]]; then
      PACKAGE_OUTPUT="$INSTALLERS_DIR/LachhhTools.exe"
    else
      PACKAGE_OUTPUT="$INSTALLERS_DIR/LachhhTools"
    fi
    ;;
  air)
    PACKAGE_OUTPUT="$INSTALLERS_DIR/LachhhTools.air"
    ;;
  *)
    echo "ERROR: PACKAGE_TARGET inválido: $PACKAGE_TARGET (use bundle|native|air|auto)."
    exit 1
    ;;
esac

echo "Empacotando aplicação ($PACKAGE_TARGET)..."
"$ADT" -package \
  -target "$PACKAGE_TARGET" \
  -storetype pkcs12 \
  -keystore "$CERT_PATH" \
  -storepass "$CERT_PASS" \
  "$PACKAGE_OUTPUT" \
  "$DESCRIPTOR_PATH" \
  -C "$BIN_DIR" TwitchGiveawayTool.swf lachhhtools_widget.swf CustomAnimationExamples icons

echo "Build concluído:"
echo "  SWF: $OUTPUT_SWF"
echo "  Pacote: $PACKAGE_OUTPUT"
