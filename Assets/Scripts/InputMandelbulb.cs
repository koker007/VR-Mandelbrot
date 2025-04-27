using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.XR;

public class InputMandelbulb : MonoBehaviour
{
    [SerializeField] private MandelbulbCTRL _mandelbulbCTRL;
    [SerializeField] private Camera _mainCamera;

    [SerializeField] private float _moveSpeed = 0.2f;

    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        Moving();
    }

    void Moving() 
    {
        Vector2 leftStick;
        Vector2 rightStick;
        bool isUpPressed;
        bool isDownPressed;

        // Получаем ввод с левого джойстика
        InputDevices.GetDeviceAtXRNode(XRNode.LeftHand).TryGetFeatureValue(
            CommonUsages.primary2DAxis, out leftStick);

        // Получаем ввод с правого джойстика (опционально)
        InputDevices.GetDeviceAtXRNode(XRNode.RightHand).TryGetFeatureValue(
            CommonUsages.secondary2DAxis, out rightStick);

        // Проверка кнопок (например, A/X на Oculus)
        InputDevices.GetDeviceAtXRNode(XRNode.LeftHand).TryGetFeatureValue(
            CommonUsages.primaryButton, out isUpPressed);
        InputDevices.GetDeviceAtXRNode(XRNode.RightHand).TryGetFeatureValue(
            CommonUsages.primaryButton, out isDownPressed);

        var position = _mandelbulbCTRL.MandelPos;
        var playerSize = _mandelbulbCTRL.PlayerSize;

        float changeSize = playerSize * _moveSpeed * Time.unscaledDeltaTime;

        position += leftStick.y * changeSize * _mainCamera.transform.forward;
        position += leftStick.x * changeSize * _mainCamera.transform.right;

        _mandelbulbCTRL.SetMandelPos(position);
    }
}
