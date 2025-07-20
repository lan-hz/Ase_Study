using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class LookAtMainCamera : MonoBehaviour
{
    // Start is called before the first frame update
    void Start()
    {
        
    }

    void LateUpdate()
    {
        transform.forward = Camera.main.transform.forward;
        transform.rotation = Camera.main.transform.rotation;
       // transform.rotation = Quaternion.LookRotation(transform.position - Camera.main.transform.position);
    }

}
