using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MandelbulbCTRL : MonoBehaviour
{
    [SerializeField]
    Vector3 mandelPos;
    [SerializeField]
    private float eyesDist = 0.3f;

    [SerializeField]
    MeshRenderer meshRendererLeft;
    [SerializeField]
    MeshRenderer meshRendererRight;

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
            meshRendererLeft?.material.SetFloat("_EyeIndex", 0.1f);
            meshRendererRight?.material.SetFloat("_EyeIndex", 0.9f);
        }
        void SetRotate() {
            //Vector3 RotOrigin = transform.rotation.eulerAngles;
            //Vector3 RotMod = new Vector3(-RotOrigin.x, -RotOrigin.y, RotOrigin.z);
            //Quaternion quaternion = new Quaternion();
            //quaternion.eulerAngles = RotMod;

            //Matrix4x4 rotationMatrix = Matrix4x4.TRS(Vector3.zero, quaternion, Vector3.one);
            Matrix4x4 rotationMatrix = Matrix4x4.TRS(Vector3.zero, transform.rotation, Vector3.one);
            meshRendererLeft?.material.SetMatrix("_RotationMatrix", rotationMatrix);
            meshRendererRight?.material.SetMatrix("_RotationMatrix", rotationMatrix);
        }
        void SetPositon() {
            float eyeDistHalf = eyesDist / 2;
            Vector3 posL = mandelPos - (transform.right * eyeDistHalf);
            Vector3 posR = mandelPos + (transform.right * eyeDistHalf);

            meshRendererLeft?.material.SetVector("_CamPos", new Vector4(posL.x, posL.y, posL.z, 0.0f));
            meshRendererRight?.material.SetVector("_CamPos", new Vector4(posR.x, posR.y, posR.z, 0.0f));
        }
    }
}
