#include <stdio.h>
#include <syslog.h>
#include <string.h>
#include <unistd.h>
#include <sys/stat.h>
#include <stdlib.h>

void decodePath(char *path, char* dirname, char*filename){
	int i, count = 0, total = 0;
	strcpy(dirname, path);
	for(i=0; i<strlen(path); i++){
		if(path[i] != NULL)
			if((path[i] == '/') && (path[i-1] != '.')&& (i != 0))
				count++;
	}		

	total = count;
	count = 0;
	
	for(i=0; ((i< strlen(path))&&(count<total)); i++)
	{
		if(path[i] != NULL){
			if((path[i] == '/')&&(path[i-1] != '.'))
				count++;
		}			
	}

	dirname[i-1] = NULL;
	strcpy(filename, &dirname[i]);
}

int isDirectoryExists(const char *path)
{
    struct stat stats;

    stat(path, &stats);

    // Check for file existence
    if (S_ISDIR(stats.st_mode))
        return 1;

    return 0;
}

int main(int argc, char* argv[]){
	char command[100];
	openlog(NULL, 0, LOG_USER);
	if(argc < 3)
	{
		syslog(LOG_ERR,"./writer.sh \"filePath\" \"text_to_write\"");
		return 1;
	}
	char dirname[50]={0},filename[50]={0};
	decodePath(argv[1], dirname, filename);
	if(!isDirectoryExists(dirname)){
		syslog(LOG_DEBUG,"not existant path\r\n");
		sprintf(command,"mkdir -p %s",dirname);
		system(command);
	}

	syslog(LOG_DEBUG,"%s\r\n",!isDirectoryExists(dirname)?"error":"exists now");

	FILE *newfile;
	newfile = fopen(argv[1],"w");
	if(newfile == NULL){
		syslog(LOG_ERR,"error creating file\r\n");
		return 1;
	}
	syslog(LOG_DEBUG,"Writing %s to %s",argv[2],argv[1]);
	fprintf(newfile,"%s",argv[2]);
	fclose(newfile);
	return 0;
}	
