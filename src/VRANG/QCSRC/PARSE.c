#include <stdio.h>
#include <string.h>

int main(int argc, char *argv[]){

  char * token = strtok(argv[1], ",");

  printf(" %s\n", token);

  return 0;
}
