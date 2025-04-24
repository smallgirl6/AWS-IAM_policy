#!/bin/bash

# 一時フォルダと出力ファイルを作成
mkdir -p tmp_json
> hash.log
> same.log
> different.log

# policy.txt の存在を確認
if [ ! -f policy.txt ]; then
  echo "policy.txt が見つかりません"
  exit 1
fi

echo "ポリシーJSONをダウンロード"

# 各ポリシーのJSONをダウンロードして保存
while read -r arn; do
  if [ -n "$arn" ]; then
    version=$(aws iam get-policy --policy-arn "$arn" --query 'Policy.DefaultVersionId' --output text 2>/dev/null)
    if [ -z "$version" ]; then
      echo "バージョンの取得に失敗：$arn"
      continue
    fi

    aws iam get-policy-version \
      --policy-arn "$arn" \
      --version-id "$version" \
      --query 'PolicyVersion.Document' \
      --output json > "tmp_json/$(basename "$arn").json" 2>/dev/null

    if [ $? -ne 0 ]; then
      echo "ダウンロード失敗：$arn"
    else
      echo "$arn を $(basename "$arn").json として保存しました"
    fi
  fi
done < policy.txt

echo "ファイルのmd5sumを計算"

# ハッシュを計算して hash.log に保存
md5sum tmp_json/*.json | sort > hash.log

# ハッシュ値の出現回数を集計
cut -d' ' -f1 hash.log | uniq -c > tmp_count.log

# same / different に分類
while read -r count hash; do
  grep "$hash" hash.log >> $( [ "$count" -gt 1 ] && echo "same.log" || echo "different.log" )
done < tmp_count.log

# tmpファイル削除
rm tmp_count.log
