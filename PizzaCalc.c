
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#define PI 3.14159265358979323846

struct pizza{
	char title[256];
	float diameter;
	float cost;
	float topr;
	struct pizza* next;
};

float area(float dia){
	return PI/4.0 * dia * dia;
}

int calc (struct pizza* pizzatocal){
	float dia = pizzatocal->diameter;
	float a = area(dia);
	float c = pizzatocal->cost;
	if(c == 0 ){
		pizzatocal->topr = 0;
		return 0;
	}
	pizzatocal->topr = a/c;	
	return 0; //I could make this a void but I like the exit :)
}

int swap(struct pizza* pizza1, struct pizza* pizza2){ //change the souls, keep the body
	struct pizza* temp = (pizza*) malloc(sizeof(struct pizza)); //placeholder
	temp->topr = pizza1->topr;
	pizza1->topr = pizza2->topr;
	pizza2->topr = temp->topr;

	strcpy(temp->title, pizza1->title);
	strcpy(pizza1->title, pizza2->title);
	strcpy(pizza2->title, temp->title);

	//adding the lines below to fully swap
	temp->diameter = pizza1->diameter;
	pizza1->diameter = pizza1->diameter;
	pizza2->diameter = temp->diameter;

	temp->cost = pizza1->cost;
	pizza1->cost = pizza1->cost;
	pizza2->cost = temp->cost;

	free(temp); //goodbye
	return 0; //I could make this a void but eh
}

int sortList(struct pizza* head){ //sorry ola everything has its uses
	int swaps = 1; //need to get into the loop
	struct pizza* pointer = head;

	while(swaps != 0){
		swaps = 0;
		pointer = head;
		while(pointer->next != NULL){
			if(pointer->topr < (pointer->next)->topr){
				swap(pointer, pointer->next);
				swaps++;
				continue;
			}

			//they're equal, alphabetize
			if(pointer->topr == pointer->next->topr){
				if(strcmp(pointer->title, pointer->next->title) > 0){
					swap(pointer, pointer->next);
					swaps++;
					continue;
				}
			}
			pointer = pointer->next; //keep going until you need to swap
		}
	}
	return 0;
}

int main(int argc, char** argv){
	char name[256];
	int count = 0;
	struct pizza* record = (pizza*) malloc(sizeof(struct pizza));
	struct pizza* head;
	struct pizza* last;

	FILE* file = fopen(argv[1], "r"); //open file for read
	
	while(true){
		
		if(fscanf(file, "%s", name) == EOF){
			printf("PIZZA FILE IS EMPTY\n");
			int check = 0; //this is for debugging, delete?
			free(record); //goodbye, you're not needed
			fclose(file); //close file, we're done
			return EXIT_SUCCESS;
		}
		if(strcmp(name, "DONE") == 0) {
			//last->next = NULL; //needed? no. line 127 does this
			if(count == 0){
				fclose(file);
				free(record);
				return EXIT_SUCCESS;
			}
			break;
		}
		if(count > 0){
			struct pizza* record2 = (pizza*) malloc(sizeof(struct pizza));
			last->next = record2;
			record = record2;
		}
	
		strcpy(record->title, name);

		float dia, c;

		fscanf(file, "%f\n", &dia); 
		record->diameter = dia;

		fscanf(file, "%f\n", &c);
		record->cost = c;

		count++;

		if(count == 1){ //if this is the first node
			head = record;
		}

		calc(record); //get the number to print
		record->next = NULL;
		last = record;
	}

	if(count > 1){ //if we only have one, we don't need to sort
		sortList(head);
	}

	struct pizza* along = head;
	while(along != NULL){
		printf("%s %f\n", along->title, along->topr);
		along = along->next;
	}

	fclose(file); //close file, we're done

	//free should be correct
	struct pizza* del = head->next; //save the pointer
	while(del != NULL){
		free(head); //goodbye
		head = del;
		del = del->next;
	}
	free(head); //goodbye final node
	
	return EXIT_SUCCESS;
}
