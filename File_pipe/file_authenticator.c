#include <stdio.h>
#include <stdlib.h>
#include <sys/stat.h>
#include <pwd.h>
#include <grp.h>
#include <unistd.h>

#define ACCESS_VAL 1;

void getAccessMetaData(const char *filepath)
{
    struct stat file_stat;
    
    if (stat(filepath, &file_stat) == -1)
    {
        perror("stat");
        exit(EXIT_FAILURE);
    }

    if((file_stat.st_mode & S_IRUSR) & !(file_stat.st_mode & S_IWUSR))
    {
        #ifndef ACCESS_VAL
        #define ACCESS_VAL 1
        #endif//read access
    }
    else if(!(file_stat.st_mode & S_IRUSR) & (file_stat.st_mode & S_IWUSR))
    {
        #ifdef ACCESS_VAL
        #undef ACCESS_VAL
        #define ACCESS_VAL 2
        #endif//write access
    }
    else if((file_stat.st_mode & S_IRUSR) & (file_stat.st_mode & S_IWUSR))
    {
        #ifdef ACCESS_VAL
        #undef ACCESS_VAL
        #define ACCESS_VAL 3
        #endif //read and write access
    }
}

void writeTo(FILE *file,int val)
{
    const int rand1=(rand()%(3))+2;
    const int rand2=(rand()%(6))+5;
    fprintf(file,"{ \"in\":[%d,%d,%d]}",rand1,val,rand2);
}

int main(int argc,char *argv[])
{
    if(argc>0)
    {
        getAccessMetaData(argv[0]);

        FILE *file=fopen("input.json","w");
        writeTo(file, ACCESS_VAL);
    }
}





























