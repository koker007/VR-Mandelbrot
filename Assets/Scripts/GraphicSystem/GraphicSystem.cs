using System;
using System.Collections;
using System.Collections.Generic;
using System.Threading.Tasks;
using OpenHardwareMonitor.Hardware;
using UnityEngine;

namespace APP
{
    public class GraphicSystem : MonoBehaviour
    {
        private const short DANGER_TEMPERATURE_GPU = 70;

        private const short FPS_MAX = 60;
        private const short FPS_MIN = 5;
        private const float FILLING_PERCENT_MINIMUM = 0.1f;

        private static GraphicSystem _instance;
        private static Computer _computer;

        private static float _temperatureGPU = -1;

        [SerializeField] private float _temperatureGPUMax = 45;
        private float _fillingPercent = 1.0f;

        public static GraphicSystem Instance => _instance;
        public float FillingPercent => _fillingPercent;

        private void Start()
        {
            Initialize();
        }

        private void Initialize()
        {
            Debug.Log($"Inisialize {nameof(GraphicSystem)}");
            if (_instance != null)
                Debug.LogError($"Try create second {nameof(GraphicSystem)} on gameObject.name == {gameObject.name}");

            _instance = this;

            _computer = new Computer() { GPUEnabled = true };
            _computer.Open();
        }

        private async void FixedUpdate()
        {
            UpdateTemperatureGPU();
            Debug.Log($"{nameof(_temperatureGPU)} {_temperatureGPU}");

            Optimize();
        }

        private async void UpdateTemperatureGPU()
        {
            await Task.Run(() =>
            {
                if (_computer == null)
                    return;

                foreach (var hardware in _computer.Hardware)
                {
                    if (hardware.HardwareType == HardwareType.GpuNvidia ||
                        hardware.HardwareType == HardwareType.GpuAti)
                    {
                        hardware.Update();
                        foreach (var sensor in hardware.Sensors)
                        {
                            if (sensor.SensorType == SensorType.Temperature)
                            {
                                _temperatureGPU = (float)sensor.Value;
                            }
                        }
                    }
                }
                return;
            });
        }

        private void Optimize() 
        {
            int fpsNow = Application.targetFrameRate;

            if (_temperatureGPUMax > DANGER_TEMPERATURE_GPU)
                _temperatureGPUMax = DANGER_TEMPERATURE_GPU;

            if (_temperatureGPU == -1)
            {
                fpsNow = FPS_MIN;
                _fillingPercent = 0.1f;
            }
            else if (_temperatureGPU > _temperatureGPUMax)
            {
                fpsNow--;

                if (fpsNow < FPS_MIN) 
                {
                    fpsNow = FPS_MIN;
                    _fillingPercent -= Time.unscaledDeltaTime * 0.1f;

                    if (_fillingPercent < FILLING_PERCENT_MINIMUM)
                        _fillingPercent = FILLING_PERCENT_MINIMUM;
                }
            }
            else 
            {
                _fillingPercent += Time.unscaledDeltaTime * 0.1f;

                if (_fillingPercent > 1.0f) 
                {
                    _fillingPercent = 1.0f;

                    fpsNow++;

                    if (fpsNow > FPS_MAX)
                        fpsNow = FPS_MAX;
                }
            }


            Application.targetFrameRate = fpsNow;
        } 
    }
}
