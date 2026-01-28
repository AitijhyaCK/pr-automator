selected_folder="$HOME/Desktop/Test"
number="$1"
 
foldername="${number}Test++"
mkdir -p "$selected_folder/$foldername"
cd "$selected_folder/$foldername"
git clone https://github.com/Qcells-Energy-Production-Team/us-qcells-salesforce.git
cd us-qcells-salesforce

branch_name="feature/PBD-${number}"

git checkout main
git pull origin main
git checkout -b "$branch_name"
git push --set-upstream origin "$branch_name"
/usr/local/bin/code .
git checkout "$branch_name"
sleep 5
/usr/local/bin/sf config set target-org "QCells UAT Moumita"
