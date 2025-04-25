using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MandelbulbCTRL : MonoBehaviour
{
    [SerializeField]
    private Vector3 _mandelPos;
    [SerializeField]
    private float _eyesDist = 0.3f;

    [SerializeField]
    private MeshRenderer _meshRendererLeft;
    [SerializeField]
    private MeshRenderer _meshRendererRight;

    private void Awake()
    {

    }

    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        UpdateData();
    }

    void UpdateData() {
        //SetEyes();
        SetRotate();
        SetPositon();

        void SetEyes() {
            _meshRendererLeft?.material.SetFloat("_EyeIndex", 0.1f);
            _meshRendererRight?.material.SetFloat("_EyeIndex", 0.9f);
        }
        void SetRotate() {
            //Vector3 RotOrigin = transform.rotation.eulerAngles;
            //Vector3 RotMod = new Vector3(-RotOrigin.x, -RotOrigin.y, RotOrigin.z);
            //Quaternion quaternion = new Quaternion();
            //quaternion.eulerAngles = RotMod;

            //Matrix4x4 rotationMatrix = Matrix4x4.TRS(Vector3.zero, quaternion, Vector3.one);
            Matrix4x4 rotationMatrix = Matrix4x4.TRS(Vector3.zero, transform.rotation, Vector3.one);
            _meshRendererLeft?.material.SetMatrix("_RotationMatrix", rotationMatrix);
            _meshRendererRight?.material.SetMatrix("_RotationMatrix", rotationMatrix);
        }
        void SetPositon() {
            float eyeDistHalf = _eyesDist / 2;
            Vector3 posL = _mandelPos - (transform.right * eyeDistHalf);
            Vector3 posR = _mandelPos + (transform.right * eyeDistHalf);

            _meshRendererLeft?.material.SetVector("_CamPos", new Vector4(posL.x, posL.y, posL.z, 0.0f));
            _meshRendererRight?.material.SetVector("_CamPos", new Vector4(posR.x, posR.y, posR.z, 0.0f));
        }
    }
}
