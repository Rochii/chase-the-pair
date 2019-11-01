/**
 *
 * @file ctp.pike
 *
 * @brief 
 *
 * @authors Roger Truchero Visa
 *
 */


// Global variables
int to_chase;
int result_a, result_b;
array(int) a, b;

// Main program
int main(int argc, array(string) argv)
{
	if(argc == 2)
	{
		to_chase = (int) argv[1];
	}
	else
	{
		write("Usage: pike ctp.pike <chase_number>\n");
		exit(0);
	}

	read_file("logs.txt");

	write("################################################################################\n");
	write("#################################### INFO ######################################\n");
	write("################################################################################\n");
 	write("\t\t\t * Size of array A: " + sizeof(a) + "\n");
 	write("\t\t\t * Size of array B: " + sizeof(b) + "\n");
 	write("\t\t\t * Chase number: " + to_chase + "\n");

 	float seconds_to_execute = gauge
 	{
		a = Array.sort(a);
	 	b = Array.sort(b);
	 	
	 	if(to_chase < a[0] || to_chase < b[0] || to_chase > a[-1] || to_chase > b[-1])
	 	{
	 		write("\t\t\t * Invalid to_chase number.\n");
	 		write("################################################################################\n\n");
	 		exit(0);
	 	}
	};
	write("\t\t\t * Seconds to sort: " + seconds_to_execute + "\n");


	seconds_to_execute = gauge
	{
		thread_version();	 
	};
	write("\t\t\t * Seconds to execute thread version: " + seconds_to_execute + "\n");


	seconds_to_execute = gauge
	{
		sequential_version();	 
	};
	write("\t\t\t * Seconds to execute sequential version: " + seconds_to_execute + "\n");
	write("################################################################################\n\n");
	
	return 0;
 }

// Function to read the file generated by setsGenerator
void read_file(string filename)
{
	string data = Stdio.read_file(filename);
	array(string) split_data = data / "-";

	a = convert_to_int_array(((split_data[0])[2..sizeof(split_data[0])-2]) / ",");
	b = convert_to_int_array(((split_data[1])[2..sizeof(split_data[1])-2]) / ",");
}

// Function to convert the string parsed array into int array
array(int) convert_to_int_array(array(string) arr)
{
	array(int) result = ({});
	foreach(arr, string elem)
	{
		result += ({ (int)elem });
	}

	return result;
}

// Function to resolve the problem with threads
void thread_version()
{	 	
	// Create two threads for each array
 	array(array(function(:void)|array)) fun_args = 
 	({
 		({ find_closest, ({ a, sizeof(a), to_chase }) }),
 		({ find_closest, ({ b, sizeof(b), to_chase }) })
 	});

	object result = Thread.Farm()->run_multiple(fun_args);

 	array(int) res = result();

	write("\t\t\t * Chase pair: [" + res[0] + ", " + res[1] + "]\n");
}

// Function to resolve the problem sequentially
void sequential_version()
{
	result_a = find_closest(a, sizeof(a), to_chase);
 	result_b = find_closest(b, sizeof(b), to_chase);
	write("\t\t\t * Chase pair: [" + result_a + ", " + result_b + "]\n");
}

// Returns element closest to to_chase in arr
int find_closest(array(int) arr, int n, int to_chase) 
{ 
    // Doing binary search 
    int i = 0, j = n, mid = 0; 

    while(i < j) 
    { 
        mid = (i + j) / 2; 
  
        if (arr[mid] == to_chase) return arr[mid]; 
  
        // If to_chase is less than array element, then search in left 
        if (to_chase < arr[mid]) 
        { 
            // If to_chase is greater than previous to mid, return closest of two 
            if (mid > 0 && to_chase > arr[mid - 1]) return get_closest(arr[mid - 1], arr[mid], to_chase); 
  
            // Repeat for left half 
            j = mid; 
        }
        else  // If to_chase is greater than mid 
        { 
            if (mid < n - 1 && to_chase < arr[mid + 1]) return get_closest(arr[mid], arr[mid + 1], to_chase); 
       
            i = mid + 1;  
        } 
    } 

    // Only single element left after search 
    return arr[mid]; 
} 
  
// Function to know which number is the closest
int get_closest(int val1, int val2, int to_chase) 
{ 
    if (to_chase - val1 >= val2 - to_chase) 
        return val2; 
    else
        return val1; 
}