pragma circom 2.1.9;

template equalsZero()
{
    signal input in;
    signal output out;

    signal temp;
    temp<==in;

    temp===0;
    out<==(1-temp)*1;
}

// template greaterThanZero()
// {
//     signal input in;
//     signal output out;

//     var temp;
//     temp=in;

//     signal truth;

//     truth<==(in>0);
    
//     out<--truth; 
//     out===1;
// }
template GreaterThanZero() {
    signal input in;         // Input signal to check
    signal output isGreater; // Output signal, 1 if 'in' > 0, 0 otherwise

    // Declare an intermediate signal to represent whether 'in' is greater than 0
    signal nonZeroCheck<==0;

    // 'nonZeroCheck' is either 0 or 1 (boolean constraint)
    nonZeroCheck * (nonZeroCheck - 1) === 0;  // Ensures 'nonZeroCheck' is 0 or 1

    // Force 'nonZeroCheck' to be 1 if 'in' is greater than 0, otherwise it must be 0
    in * (1 - nonZeroCheck) === 0;  // If 'in' is not zero, 'nonZeroCheck' must be 1

    // Assign the output to 'nonZeroCheck' since it represents whether 'in' > 0
    isGreater <== nonZeroCheck;
}

template lesserThanZero(value)
{

}

template isFactor(value)
{

}

template maxValue()
{

}

template minValue()
{

}


component main = GreaterThanZero();