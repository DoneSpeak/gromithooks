# 根据分支名，自动添加tapd关联字符串
#
# 添加环境变量：TAPD_USERNAME=donespeak
#
# 分支名  | commit 格式 | 绑定TAPD
# --- | --- | ---
# tapd-S1234  | #S1234, message  | --story=1234 --user=donespeak
# tapd-B1234  | #B1234, message  | --bug=1234 --user=donespeak
# tapd-T1234   | #T1234, message  | --task=1234 --user=donespeak
# tapd-S1234-fix-bug  | #S1234, message  | --story=1234 --user=donespeak

import sys, os, re
from subprocess import check_output
from typing import Optional
from typing import Sequence

def findTapdUsername():
    tapd_username = os.getenv('TAPD_USERNAME')
    return tapd_username

def findTapdIdFromMsg(content: str):
    # 匹配如：tapd-123, tapd-1234-fix
    result = re.match('^#([STB]\d+)[^0-9a-zA-Z]', content)
    if not result:
        # 分支名不符合
        return None
    return result.group(1)

def findTapdIdFromBranch():
    # 检测我们所在的分支
    branch = check_output(['git', 'symbolic-ref', '--short', 'HEAD']).strip().decode('utf-8')

    # 匹配如：tapd-123, tapd-1234-fix
    result = re.match('^tapd-([STB]\d+)((-.*)+)?$', branch)
    if not result:
        # 分支名不符合
        return None
    return result.group(1)

def checkMsgHasTapdRef(content: str):
    TAPD_REFER_REX = "--(story|task|bug)=[0-9]+[ ]+--user="
    TAPD_REFER_MSG_REX = ".*" + TAPD_REFER_REX + ".*"
    return re.search(TAPD_REFER_MSG_REX, content)

def showBranchNameFormatWarn():
    warning = """
    WARN: The format of branch name and commit message is incorrect.
    The format of branch should be tapd-[STB]<tapdId> (example: tapd-S12345);
    Or the commit message should start with #[STB]<tapdId> (example: #S12345, message).
    """
    print(warning)

def showTapdUsernameRequireWarn():
    warning = """
    WARN: environment value TAPD_USERNAME is required. You can config with the following commands.
    (Replace [yourname] with your name in Tapd. Using .zshrc instead of .bash_profile if zsh)

        echo -e '\\nexport TAPD_USERNAME=\"[yourname]\" >> ~/.bash_profile"
        source ~/.bash_profile"
    """
    print(warning)

def extendTapdType(tapd_type_char: str):
    tapd_types = {
        'S' : "story",
        'T' : "task",
        'B' : "bug"
    }
    return tapd_types.get(tapd_type_char, None)

def generateTapdRef(tapd_id: str, tapd_username: str):
    tapd_type = extendTapdType(tapd_id[0:1])
    tapd_number = tapd_id[1:]
    tapd_ref = "--{}={} --user={}".format(tapd_type, tapd_number, tapd_username)
    return tapd_ref

def main(argv: Optional[Sequence[str]] = None) -> int:
    commit_msg_filepath = sys.argv[1]
    content = ''
    with open(commit_msg_filepath, 'r+') as f:
        content = f.read()
    if checkMsgHasTapdRef(content):
        # print("There is tapd ref in commit message.")
        return
    tapd_id = findTapdIdFromMsg(content)
    if not tapd_id:
        tapd_id = findTapdIdFromBranch()
    if not tapd_id:
        showBranchNameFormatWarn()
        # print("Tapd id not found in branch name.")
        return
    tapd_username = findTapdUsername()
    if not tapd_username:
        showTapdUsernameRequireWarn()
        return
    tapd_ref = generateTapdRef(tapd_id, tapd_username)
    with open(commit_msg_filepath, 'r+') as f:
        f.write("%s\n\n%s" % (content, tapd_ref))
        # print('Add tapd ref to commit message.')

if __name__ == '__main__':
    exit(main())
