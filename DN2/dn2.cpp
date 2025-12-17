#include <iostream>
#include <cmath>

using namespace std;

// konstanta pi (ker M_PI v Visual Studiu ni definirana)
const double PI = 3.14159265358979323846;

// Taylorjev razvoj za arctan(x), |x| < 1
double calctan(double* x, int* N_steps)
{
    double sum = 0.0;

    for (int n = 0; n < *N_steps; n++)
    {
        sum += pow(-1, n) * pow(*x, 2 * n + 1) / (2 * n + 1);
    }

    return sum;
}

// f(x) = e^(3x) * arctan(x/2)
double f(double x, int N_steps)
{
    double arg = x / 2.0;
    return exp(3.0 * x) * calctan(&arg, &N_steps);
}

int main()
{
    // meje integracije
    double a = 0.0;
    double b = PI / 4.0;

    // parametri
    int n = 1000;        // število trapezov
    int N_steps = 50;    // število členov Taylorjeve vrste

    double h = (b - a) / n;
    double integral = 0.0;

    // trapezna metoda
    integral += f(a, N_steps);
    integral += f(b, N_steps);

    for (int i = 1; i < n; i++)
    {
        double x = a + i * h;
        integral += 2.0 * f(x, N_steps);
    }

    integral *= h / 2.0;

    // izpis rezultata
    cout << "Priblizek integrala je: " << integral << endl;

    return 0;
}
