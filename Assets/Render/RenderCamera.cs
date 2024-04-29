using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class RenderCamera : MonoBehaviour
{
    [SerializeField]
    Camera camera;

    private void OnPreRender()
    {

        camera.Render();
    }
    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {

    }
}
