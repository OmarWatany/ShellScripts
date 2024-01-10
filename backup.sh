
# backup documents folder
#
# rsync -avhP --delete $HOME/Documents/ /media/exdrive/Documents
case $1 in
    "dry")
        rsync -avhP --dry-run --delete $HOME/Documents/ $HOME/exdrive/Documents
        ;;
    "run")
        rsync -avhP --delete $HOME/Documents/ $HOME/exdrive/Documents
        ;;
    *) ;;
esac;
