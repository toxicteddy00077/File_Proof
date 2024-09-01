pragma circom 2.1.9;

template readCheck(n) {

    // Declaration of signals.
    signal input in[n];
    signal output out;

    var i;
    signal check[n];
    signal isOne[n];
    for(i=0;i<n;i++)
    {   
        isOne[i]<==(in[i])*(in[i]-1);
        check[i]<==isOne[i];
    }

    var inverse=1/n;
    var sum;
    var j;
    for(j=0;j<n;j++)
    {
        sum+=check[j];
    }

    signal temp<==sum*inverse;
    out<==temp;
}
