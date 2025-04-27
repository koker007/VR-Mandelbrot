using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using APP;

public class MandelbulbCTRL : MonoBehaviour
{
    [SerializeField]
    private float _playerSize = 1.0f;

    [SerializeField]
    private Camera _mainCamera;
    [SerializeField]
    private Vector3 _mandelPos;
    [SerializeField]
    private float _eyesDist = 0.3f;

    [SerializeField]
    private MeshRenderer _meshRendererLeft;
    [SerializeField]
    private MeshRenderer _meshRendererRight;

    private Vector3 baceOffset = new Vector3();

    public float PlayerSize => _playerSize;
    public Vector3 MandelPos => _mandelPos;

    private void Awake()
    {

    }

    // Start is called before the first frame update
    private void Start()
    {
        
    }

    // Update is called once per frame
    private void Update()
    {
        UpdateData();
    }

    private void UpdateData() {
        UpdateOffset();

        SetOther();

        SetEyes();
        SetRotate();
        SetPositon();

        void SetOther() 
        {
            var fillingPercent = GraphicSystem.Instance.FillingPercent;

            _meshRendererLeft?.material.SetFloat("_FillingPercent", fillingPercent);
            _meshRendererRight?.material.SetFloat("_FillingPercent", fillingPercent);
        }
        void UpdateOffset() 
        {
            if (baceOffset == Vector3.zero && _mainCamera.transform.localPosition != Vector3.zero)
                baceOffset = _mainCamera.transform.localPosition;
        }
        void SetEyes() {
            _meshRendererLeft?.material.SetFloat("_EyeIndex", 0.1f);
            _meshRendererRight?.material.SetFloat("_EyeIndex", 0.9f);
        }
        void SetRotate() {
            Matrix4x4 rotationMatrix = CreateRotationMatrix(_mainCamera.transform.rotation);
            _meshRendererLeft?.material.SetMatrix("_RotationMatrix", rotationMatrix);
            _meshRendererRight?.material.SetMatrix("_RotationMatrix", rotationMatrix);
        }
        void SetPositon() {
            float eyeDistHalf = _eyesDist / 2 * _playerSize;

            Vector3 centerPos = _mandelPos + (_mainCamera.transform.localPosition - baceOffset) * _playerSize;

            Vector3 posL = centerPos - (transform.right * eyeDistHalf);
            Vector3 posR = centerPos + (transform.right * eyeDistHalf);

            _meshRendererLeft?.material.SetVector("_CamPos", new Vector4(posL.x, posL.y, posL.z, 0.0f));
            _meshRendererRight?.material.SetVector("_CamPos", new Vector4(posR.x, posR.y, posR.z, 0.0f));
        }
    }

    Matrix4x4 CreateRotationMatrix(Quaternion quaternion)
    {
        float radYaw = Mathf.Deg2Rad * -quaternion.eulerAngles.y;// yaw;
        float radPitch = Mathf.Deg2Rad * -quaternion.eulerAngles.x; //pitch;
        float radRoll = Mathf.Deg2Rad * -quaternion.eulerAngles.z;

        Matrix4x4 yawMatrix = new Matrix4x4(
            new Vector4(Mathf.Cos(radYaw), 0, Mathf.Sin(radYaw), 0),
            new Vector4(0, 1, 0, 0),
            new Vector4(-Mathf.Sin(radYaw), 0, Mathf.Cos(radYaw), 0),
            new Vector4(0, 0, 0, 1)
        );

        Matrix4x4 pitchMatrix = new Matrix4x4(
            new Vector4(1, 0, 0, 0),
            new Vector4(0, Mathf.Cos(radPitch), -Mathf.Sin(radPitch), 0),
            new Vector4(0, Mathf.Sin(radPitch), Mathf.Cos(radPitch), 0),
            new Vector4(0, 0, 0, 1)
        );

        Matrix4x4 rollMatrix = new Matrix4x4(
            new Vector4(Mathf.Cos(radRoll), -Mathf.Sin(radRoll), 0, 0),
            new Vector4(Mathf.Sin(radRoll), Mathf.Cos(radRoll), 0, 0),
            new Vector4(0, 0, 1, 0),
            new Vector4(0, 0, 0, 1)
        );

        return yawMatrix * pitchMatrix * rollMatrix;
    }

    public void SetMandelPos(Vector3 positionNew) 
    {
        _mandelPos = positionNew;
    }
    public void SetPlayerSize(float sizeNew) 
    {
        _playerSize = sizeNew;
    }
}
