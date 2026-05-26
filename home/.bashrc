case $- in
    *i*)
        ;;
    *)
        return 0
        ;;
esac

[ -r "$HOME/.profile" ] && . "$HOME/.profile"
