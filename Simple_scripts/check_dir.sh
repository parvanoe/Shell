echo "Please enter the full directory path you search for:"
read path
echo "Searching ..... "
if [ -d $path ]
then 
   echo "Directory exists"
else
   echo "Directory not found"
fi
