#!/bin/sh
set -e

if [ -z "$2" ]; then
    echo "Usage: $0 [version] <dest_dir>"
    echo "  version    可选，为空时目标文件为 libnvshare.so"
    echo "  dest_dir   必填，目标目录"
    exit 1
fi
VERSION="$1"
DEST_DIR="$2"

SOURCE_FILE=/usr/local/bin/libnvshare.so

if [ -z "$VERSION" ]; then
    DEST_FILE="${DEST_DIR}/libnvshare.so"
else
    DEST_FILE="${DEST_DIR}/libnvshare.so.${VERSION}"
fi

if [ ! -d "$DEST_DIR" ]; then
    mkdir -p "$DEST_DIR"
    echo "Created directory: $DEST_DIR"
fi

if [ -d "$DEST_FILE" ]; then
    rm -rf "$DEST_FILE"
    echo "Removed stale directory: $DEST_FILE"
fi

if [ -f "$DEST_FILE" ]; then
    src_md5=$(md5sum "$SOURCE_FILE" | awk '{print $1}')
    dst_md5=$(md5sum "$DEST_FILE"  | awk '{print $1}')
    if [ "$src_md5" = "$dst_md5" ]; then
        echo "Skipped (same MD5): $DEST_FILE"
        exit 0
    fi
    echo "MD5 differs, replacing: $DEST_FILE"
fi

cp "$SOURCE_FILE" "${DEST_FILE}.tmp"
mv -f "${DEST_FILE}.tmp" "$DEST_FILE"
echo "Installed: $SOURCE_FILE -> $DEST_FILE"
