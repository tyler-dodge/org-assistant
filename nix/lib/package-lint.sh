unset PATH
for p in $baseInputs $buildInputs; do
  export PATH=$p/bin${PATH:+:}$PATH
done

function buildPhase() {
    ln -s $test_target test
    mkdir home
    export HOME=home/
    ${emacs}/bin/emacs -q --version
    source $build_targets
    wget -O melpazoid.el https://raw.githubusercontent.com/riscy/melpazoid/master/melpazoid/melpazoid.el
    ${emacs}/bin/emacs -q -batch \
            --load "${emacs_start}" \
            --eval "(package-install-file \"melpazoid.el\")" \
            --load "${run_package_lint}" | tee $out
    STATUS="${PIPESTATUS[0]}"
    if [ $STATUS -gt 0 ]
    then
        rm $out
        exit $STATUS
    fi
}

function genericBuild() {
  buildPhase
}

