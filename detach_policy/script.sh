#!/bin/bash

# ファイルからポリシーARNを読み込む
POLICY_ARN=$(< policy.txt)

# IAMユーザーの一覧ファイル
USER_FILE="IAMuser.txt"

# ユーザーを1行ずつ読み込み、ポリシーをデタッチする
while IFS= read -r IAM_USER || [[ -n "$IAM_USER" ]]; do
  if [[ -n "$IAM_USER" ]]; then
    echo "ポリシーをデタッチ中：$POLICY_ARN ← ユーザー: $IAM_USER"
    aws iam detach-user-policy \
      --user-name "$IAM_USER" \
      --policy-arn "$POLICY_ARN"

    if [ $? -eq 0 ]; then
      echo "✅ $IAM_USER から正常にデタッチされました"
      echo "$IAM_USER" >> detach_success.log
    else
      echo "❌ デタッチ失敗：$IAM_USER"
      echo "$IAM_USER" >> detach_failed.log
    fi
  fi
done < "$USER_FILE"

