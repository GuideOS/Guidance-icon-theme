#!/bin/bash

ROOT_UID=0
DEST_DIR=

# Destination directory
if [ "$UID" -eq "$ROOT_UID" ]; then
  DEST_DIR="/usr/share/icons"
else
  DEST_DIR="$HOME/.local/share/icons"
fi

SRC_DIR=$(cd $(dirname $0) && pwd)

THEME_NAME=Guidance
COLOR_VARIANTS=('' '-dark')

install() {
  local dest=${1}
  local name=${2}
  local color=${3}

  local THEME_DIR=${dest}/${name}${theme}${color}

  [[ -d ${THEME_DIR} ]] && rm -rf ${THEME_DIR}

  echo "Installing '${THEME_DIR}'..."

  mkdir -p                                                                             ${THEME_DIR}
  cp -r ${SRC_DIR}/{COPYING,AUTHORS}                                                   ${THEME_DIR}
  cp -r ${SRC_DIR}/src/index.theme                                                     ${THEME_DIR}

  if [[ $DESKTOP_SESSION == '/usr/share/xsessions/plasma' && ${color} == '' ]]; then
    sed -i "s/Adwaita/breeze/g" ${THEME_DIR}/index.theme
  fi

  if [[ $DESKTOP_SESSION == '/usr/share/xsessions/plasma' && ${color} == '-dark' ]]; then
    sed -i "s/Adwaita/breeze-dark/g" ${THEME_DIR}/index.theme
  fi

  cd ${THEME_DIR}
  sed -i "s/${name}/${name}${theme}${color}/g" index.theme

  if [[ ${color} == '' ]]; then
    mkdir -p                                                                               ${THEME_DIR}/status
    cp -r ${SRC_DIR}/src/{actions,animations,apps,categories,devices,emblems,mimes,places} ${THEME_DIR}
    cp -r ${SRC_DIR}/src/status/{16,22,24,32,symbolic}                                     ${THEME_DIR}/status

    if [[ ${white} == 'true' ]]; then
      sed -i "s/#363636/#dedede/g" "${THEME_DIR}"/status/{16,22,24}/*
    fi

    cp -r ${SRC_DIR}/links/{actions,apps,categories,devices,emblems,mimes,places,status} ${THEME_DIR}
  fi

  if [[ ${color} == '' && ${theme} != '' ]]; then
    cp -r ${SRC_DIR}/colorful-folder/folder${theme}/*.svg                              ${THEME_DIR}/places/48
  fi


  if [[ ${color} == '' && $DESKTOP_SESSION == '/usr/share/xsessions/budgie-desktop' ]]; then
    cp -r ${SRC_DIR}/src/status/symbolic-budgie/*.svg                                  ${THEME_DIR}/status/symbolic
  fi

  if [[ ${color} == '-dark' ]]; then
    mkdir -p                                                                           ${THEME_DIR}/{apps,categories,emblems,devices,mimes,places,status}

    cp -r ${SRC_DIR}/src/actions                                                       ${THEME_DIR}
    cp -r ${SRC_DIR}/src/apps/symbolic                                                 ${THEME_DIR}/apps
    cp -r ${SRC_DIR}/src/categories/symbolic                                           ${THEME_DIR}/categories
    cp -r ${SRC_DIR}/src/emblems/symbolic                                              ${THEME_DIR}/emblems
    cp -r ${SRC_DIR}/src/mimes/symbolic                                                ${THEME_DIR}/mimes
    cp -r ${SRC_DIR}/src/devices/{16,22,24,symbolic}                                   ${THEME_DIR}/devices
    cp -r ${SRC_DIR}/src/places/{16,22,24,symbolic}                                    ${THEME_DIR}/places
    cp -r ${SRC_DIR}/src/status/{16,22,24,symbolic}                                    ${THEME_DIR}/status

    # Change icon color for dark theme
    sed -i "s/#363636/#dedede/g" "${THEME_DIR}"/{actions,devices,places,status}/{16,22,24}/*
    sed -i "s/#363636/#dedede/g" "${THEME_DIR}"/{actions,apps,categories,emblems,devices,mimes,places,status}/symbolic/*

    cp -r ${SRC_DIR}/links/actions/{16,22,24,symbolic}                                 ${THEME_DIR}/actions
    cp -r ${SRC_DIR}/links/devices/{16,22,24,symbolic}                                 ${THEME_DIR}/devices
    cp -r ${SRC_DIR}/links/places/{16,22,24,symbolic}                                  ${THEME_DIR}/places
    cp -r ${SRC_DIR}/links/status/{16,22,24,symbolic}                                  ${THEME_DIR}/status
    cp -r ${SRC_DIR}/links/apps/symbolic                                               ${THEME_DIR}/apps
    cp -r ${SRC_DIR}/links/categories/symbolic                                         ${THEME_DIR}/categories
    cp -r ${SRC_DIR}/links/mimes/symbolic                                              ${THEME_DIR}/mimes

    cd ${dest}
    ln -s ../${name}${theme}/animations ${name}${theme}-dark/animations
    ln -s ../../${name}${theme}/categories/32 ${name}${theme}-dark/categories/32
    ln -s ../../${name}${theme}/emblems/16 ${name}${theme}-dark/emblems/16
    ln -s ../../${name}${theme}/emblems/22 ${name}${theme}-dark/emblems/22
    ln -s ../../${name}${theme}/emblems/24 ${name}${theme}-dark/emblems/24
    ln -s ../../${name}${theme}/mimes/48 ${name}${theme}-dark/mimes/48
    ln -s ../../${name}${theme}/apps/scalable ${name}${theme}-dark/apps/scalable
    ln -s ../../${name}${theme}/devices/scalable ${name}${theme}-dark/devices/scalable
    ln -s ../../${name}${theme}/places/48 ${name}${theme}-dark/places/48
    ln -s ../../${name}${theme}/status/32 ${name}${theme}-dark/status/32

    cd ${THEME_DIR}
    sed -i "s/Numix-Circle-Light/Numix-Circle/g" index.theme
  fi

  cd ${THEME_DIR}
  ln -sf actions actions@2x
  ln -sf animations animations@2x
  ln -sf apps apps@2x
  ln -sf categories categories@2x
  ln -sf devices devices@2x
  ln -sf emblems emblems@2x
  ln -sf mimes mimes@2x
  ln -sf places places@2x
  ln -sf status status@2x

  cd ${dest}
  gtk-update-icon-cache ${name}${theme}${color}
}

while [[ $# -gt 0 ]]; do
  case "${1}" in
    -d|--dest)
      dest="${2}"
      if [[ ! -d "${dest}" ]]; then
        echo "ERROR: Destination directory does not exist."
        exit 1
      fi
      shift 2
      ;;
    -n|--name)
      name="${2}"
      shift 2
      ;;
    -blue)
      theme="-blue"
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "ERROR: Unrecognized installation option '$1'."
      echo "Try '$0 --help' for more information."
      exit 1
      ;;
  esac
  shift
done

install_theme() {
  for color in "${colors[@]-${COLOR_VARIANTS[@]}}"; do
    install "${dest:-${DEST_DIR}}" "${name:-${THEME_NAME}}" "${color}"
  done
}

if [[ "${all}" == 'true' ]]; then
  install_all
  else
  install_theme
fi
