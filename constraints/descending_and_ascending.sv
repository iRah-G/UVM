/************************
Write a Constraint for array size b/w 20 & 30 and the values of array in descending order
Generate another array with size b/w 10:20 and values in ascending order
*************************/

class packet;

    rand int arr[];
    rand int arr_asc[];

    constraint c_size{
        arr.size() inside[20:30];
    }

    constraint c_size_asc{
        arr_asc.size() inside[10:20];
    }

    constraint c_descending{
        foreach (arr[i])
        { if(i == 1)
            arr[i-1] > arr[i];
        }
    }

    constraint c_ascending{
        foreach (arr_asc[i])
        { if(i == 1)
            arr_asc[ i - 1] < arr_asc[i];
        }
    }

endclass

