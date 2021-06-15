# 根据分支名，自动添加commit message前缀
#
# 分支名  | commit 格式 | 绑定TAPD
# --- | --- | ---
# tapd-S1234  | #S1234, message  | story 1234
# tapd-B1234  | #B1234, message  | bug 1234
# tapd-T1234   | #T1234, message  | task 1234
# tapd-S1234-fix-bug  | #S1234, message  | story 1234

import sys, os, re
from subprocess import check_output
from typing import Optional
from typing import Sequence

def findTapdIdFromBranch():
    # 检测我们所在的分支
    branch = check_output(['git', 'symbolic-ref', '--short', 'HEAD']).strip().decode('utf-8')

    # 匹配如：tapd-123, tapd-1234-fix
    result = re.match('^tapd-([STB]\d+)((-.*)+)?$', branch)
    if not result:
        # 分支名不符合
        return None
    return result.group(1)

def main(argv: Optional[Sequence[str]] = None) -> int:
    commit_msg_filepath = sys.argv[1]
    tapd_id = findTapdIdFromBranch()
    if not tapd_id:
        warning = "WARN: Unable to add issue prefix since the format of the branch name dismatch."
        warning += "\nThe branch name format shoud be [STB]<issue number>, example S100011"
        print(warning)
        return

    with open(commit_msg_filepath, 'r+') as f:
        content = f.read()
        if re.search('^#[STB][0-9]+(.*)', content):
            # print('Abort:There is tapd prefix in commit message.')
            return
        issue_prefix = '#' + tapd_id
        f.seek(0, 0)
        f.write("%s, %s" % (issue_prefix, content))
        # print('Add tapd prefix %s to commit message.' % issue_prefix)

if __name__ == '__main__':
    exit(main())
