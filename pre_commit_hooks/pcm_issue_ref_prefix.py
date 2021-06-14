import sys, os
import argparse

sys.argv[1]

def main(argv: Optional[Sequence[str]] = None) -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument('filenames', nargs='*', help='Filenames to fix')
    args = parser.parse_args(argv)

    for arg in args.filenames:
        print(arg)

if __name__ == '__main__':
    exit(main())
