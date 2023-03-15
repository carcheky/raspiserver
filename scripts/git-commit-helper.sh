git config --global user.email "carcheky@gmail.com"
git config --global user.name "carcheky"
git add .


# if $1 is not empty, use it as commit message
if [ -n "$1" ]; then
    git commit -m "$1"
    git push
    exit 0
fi

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


# ask commit message
echo "Enter commit message:"
read commitMessage

# commit
git commit -m "$yn: $commitMessage"
# git push
