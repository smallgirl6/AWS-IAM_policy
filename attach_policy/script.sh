#!/bin/bash

# ファイルからポリシーARNを読み込む
POLICY_ARN=$(< policy.txt)

# IAMユーザーの一覧ファイル
USER_FILE="IAMuser.txt"

# ユーザーを1行ずつ読み込み、ポリシーをアタッチする
while IFS= read -r IAM_USER || [[ -n "$IAM_USER" ]]; do
  if [[ -n "$IAM_USER" ]]; then
    echo "ポリシーをアタッチ中：$POLICY_ARN → ユーザー: $IAM_USER"
    aws iam attach-user-policy \
      --user-name "$IAM_USER" \
      --policy-arn "$POLICY_ARN"

    if [ $? -eq 0 ]; then
      echo "✅ $IAM_USER に正常にアタッチされました"
      echo "$IAM_USER" >> attach_success.log
    else
      echo "❌ アタッチ失敗：$IAM_USER"
      echo "$IAM_USER" >> attach_failed.log
    fi
  fi
done < "$USER_FILE"
