# 中文 fork 发布

中文发行使用 `cn` 分支上的 **Actions → cn-release → Run workflow**。选择 `cn`，填写 `cn-v<清单版本>-<批次>` 标签；清单版本来自 `AndroidManifest.xml`，批次为正整数。上游 `create-release` 仍从 `main` 发布，不用于中文分支。

首次运行前，在本仓库 Settings → Secrets and variables → Actions 配置四个 repository secrets：

- `ANDROID_KEYSTORE_B64`：固定签名 keystore 的 Base64 内容。
- `ANDROID_KEYSTORE_PASSWORD`：keystore 密码。
- `ANDROID_KEY_ALIAS`：密钥别名。
- `ANDROID_KEY_PASSWORD`：密钥密码。

密钥只放入 Secrets，不提交到源码、Release 或日志。请备份同一份密钥，后续发布继续使用；丢失密钥将无法覆盖升级已有安装。缺少任一 Secret，流程会停止，不会生成临时签名发行包。

工作流会校验标签，运行测试，用原工具链执行 `RELEASE=1 ./build.sh`，再上传 `RecipeLab.apk` 与 SHA-256 文件。附件下载比对通过后才公开发布。已有同名草稿可以继续；已公开的 Release 和已有标签指向的提交不能被替换。

中文批次标签不修改 APK 内版本。未来正式升级仍需按上游版本规则推进清单版本；不要把批次号当作 Android 的 versionCode。
