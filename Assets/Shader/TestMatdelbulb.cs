using System;

public class Mandelbulb
{
    public int MaxIterations { get; set; } = 100;
    public double Power { get; set; } = 8; // Мощность для мундельбульба

    public double Calculate(double x, double y, double z)
    {
        double r = 0.0;
        double theta, phi;
        double newx = x, newy = y, newz = z;
        int iteration = 0;

        while (r < 4.0 && iteration < MaxIterations)
        {
            r = newx * newx + newy * newy + newz * newz;
            theta = Math.Acos(newz / Math.Sqrt(r));
            phi = Math.Atan2(newy, newx);
            double rn = Math.Pow(r, Power / 2);

            newx = rn * Math.Sin(Power * theta) * Math.Cos(Power * phi) + x;
            newy = rn * Math.Sin(Power * theta) * Math.Sin(Power * phi) + y;
            newz = rn * Math.Cos(Power * theta) + z;

            iteration++;
        }

        return iteration;
    }
}