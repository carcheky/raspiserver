git config --global user.email "carcheky@gmail.com"
git config --global user.name "carcheky"
git add .

# ask commit type
echo "What type of commit is this?"
select yn in "feat" "fix" "docs" "style" "refactor" "perf" "test" "chore" "revert"; do
    case $yn in
        feat ) break;;
        fix ) break;;
        docs ) break;;
        style ) break;;
        refactor ) break;;
        perf ) break;;
        test ) break;;
        chore ) break;;
        revert ) break;;
    esac
done

# ask commit scope
echo "What is the scope of this commit?"
select yn in "core" "ui" "docs" "tests" "deps" "build" "ci" "perf" "refactor" "revert"; do
    case $yn in
        core ) break;;
        ui ) break;;
        docs ) break;;
        tests ) break;;
        deps ) break;;
        build ) break;;
        ci ) break;;
        perf ) break;;
        refactor ) break;;
        revert ) break;;
    esac
done

# ask commit message
echo "Enter commit message:"
read commitMessage

# commit
git commit -m "${yn}(${REPLY}): ${commitMessage}"
git push
