function yes_or_no {
    while true; do
        read -p "$* [y/n]: " yn
        case $yn in
            [Yy]*) return 0  ;;  
            [Nn]*) echo "Aborted" ; return  1 ;;
        esac
    done
}

yes_or_no "Download Anaconda 5.3?" && \
echo "dowing something" && \
echo "doing someth8ing else"