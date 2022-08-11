# Release

本仓库负责管理 linuxdeepin 所有项目的分支与仓库配置。

本项目需要实现两个任务：

- [ ] tag 创建
- [ ] 版本发布

## 执行流程

在明道云创建 tag 同步流程，并选择需要同步的项目、对应的 commit hash 和 tag，在发起流程后，由机器人创建一份 pull request 提交。

在 pull request 提交中，需要通过 commit 和 hash 的合规 check，当 check 通过后，由机器人同意审批，并通过当前流程，等待全部流程结束。

在全部流程审批通过后，pull request 会被合并，并且会执行 action 将 tag 全部同步。

## repository

该目录存放着 linuxdeepin 所有开源项目的发布版本，所有在 github 上发布的 tag 均使用该目录进行自动更新。


配置文件的文件名必须是项目名称，配置文件的描述如下:


```json
{
    "apiVersion": "1.0",
    "repo": "dde-api",
    "data": {
        "tagger": {
            "name": "justforlxz",
            "email": "justforlxz@gmail.com"
        },
        "message": "1050 update1",
        "object": "48b26758cf477c49f60e29f43a3ccde79adccf1d",
        "tag": "5.5.25"
    }
}
```

### 字段说明

- version

  version 对象包含一个版本发布所需的所有信息。

  - sha

    sha 是一个版本所对应的 commit hash。

  - tag

    tag 是一次发布所需要的版本号，需要满足版本号发布规范。

  - title

    版本发布所需的标题。

  - description

    版本发布所需的描述。

  - author

    申请创建 tag 的作者姓名

  - email

    申请创建 tag 的作者邮箱
