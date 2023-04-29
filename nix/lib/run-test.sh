unset PATH
for p in $baseInputs $buildInputs; do
  export PATH=$p/bin${PATH:+:}$PATH
done

function buildPhase() {
    ln -s $test_target test
    mkdir home
    export HOME=home/
    ${emacs}/bin/emacs -q --version
    ln -s "$el_target" "$el_name"
    ${emacs}/bin/emacs -q --batch \
            --eval "(require 'package)" \
            --eval "(add-to-list 'package-archives '(\"melpa\" . \"https://melpa.org/packages/\") t)" \
            --eval "(package-initialize)" \
            --eval "(package-refresh-contents)" \
            --eval "(package-install-file \"${el_name}\")" \
            -l ert-runner | tee $out
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
