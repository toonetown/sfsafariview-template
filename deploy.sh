#!/bin/bash
cd "$(dirname "${0}")"
SOURCE="$(pwd)"
cd ->/dev/null
TARGET="${1}"

[ -n "${TARGET}" ] || {
    echo "Usage: ${0} [/path/to/proj_output] </path/to/config>"
    exit 1
}
[ ! -e "${TARGET}" ] || {
    echo "Cannot copy to existing location ${TARGET}"
    exit 1
}
[ -d "$(dirname "${TARGET}")" ] || {
    echo "Directory $(dirname "${TARGET}") does not exist"
    exit 1
}

# Source our configuration (if it's set)
if [ -f "${2}" ]; then source "${2}" || exit $?; fi
    
TGT_NAME="$(basename "${TARGET}")"
: ${TAG_NAME:="sfsv"}
: ${SRC_NAME:="__${TAG_NAME}_template__"}

# Tags to replace
TGT_TAGS="name identifier version url red green blue btnRed btnGreen btnBlue"
: ${TGT_name:="${TGT_NAME}"}
: ${TGT_identifier:="com.toonetown.$(echo "${TGT_name}" | sed -e 's/ /-/g')"}
: ${TGT_version:="1.0"}

for _T in ${TGT_TAGS} ICON; do
    _V="TGT_${_T}"; [ -n "${!_V}" ] || { echo "You must specify ${_V}"; exit 1; }
done

echo "Copying to '${TARGET}'..."
cp -R "${SOURCE}" "${TARGET}" || exit $?

echo "Cleaning up unneeded files..."
# git -C "${TARGET}" clean -fxd &>/dev/null
rm -rf "${TARGET}/"{.git,.gitignore,README.md,configs,__sfsv_template__/Bridging-Header.h} \
       "${TARGET}/$(basename "${0}")" &>/dev/null
find "${TARGET}" -name ".DS_Store" -exec rm -f {} \; &>/dev/null
find "${TARGET}" -name "xcuserdata" -type d -exec rm -rf {} \; &>/dev/null

echo "Renaming files..."
find "${TARGET}" -d -name "${SRC_NAME}*" -print0 | while IFS= read -r -d '' _F; do
    mv "${_F}" "$(echo "${_F}" | sed -E "s/${SRC_NAME}([\._][^\.]*)?$/${TGT_NAME}\1/g")" || exit $?
done

echo "Update project name to ${TGT_NAME}..."
find "${TARGET}" -type f -print0 | while IFS= read -r -d '' _F; do
    [[ "$(file -b --mime-encoding "${_F}")" = binary ]] && continue
    sed -i '' -e "s/${SRC_NAME}/${TGT_NAME}/g" "${_F}" || exit $?
    sed -i '' -e "/Bridging-Header\.h/d" "${_F}" || exit $?
done

for _T in ${TGT_TAGS}; do
    _V="TGT_${_T}"
    echo "Update ${_T} to ${!_V}..."
    find "${TARGET}" -type f -print0 | while IFS= read -r -d '' _F; do
        [[ "$(file -b --mime-encoding "${_F}")" = binary ]] && continue
        sed -i '' -e "s|[_-][_-]${TAG_NAME}[_-]template[_-]${_T}[_-][_-]|${!_V}|g" "${_F}" || exit $?
    done
done

echo "Generating icons..."
find "${TARGET}" -type d -name '*.appiconset' -print0 | while IFS= read -r -d '' _D; do
    _C="${_D}/Contents.json"
    rm -f "${_D}"/*.png
    for _F in $(grep 'filename' "${_C}" | cut -d'"' -f4 | sort -u); do
        _R="$(echo "${_F}" | sed -En 's/^.*-([0-9]+).*/\1/p')" || exit $?
        convert -monitor -density 300 "${TGT_ICON}" -resize ${_R}x${_R} "${_D}/${_F}" || exit $?
    done
done

echo "Done!  App deployed to '${TARGET}'"
exit 0
