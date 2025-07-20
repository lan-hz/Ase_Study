using UnityEngine;
using ZWS.Equips;

namespace TestSign
{
    public class TestSign : MonoBehaviour
    {
        SetMobileSign sign;

        private void Start()
        {
            sign = new SetMobileSign(this.transform);
        }

        private void Update()
        {
            if (Input.GetKeyDown(KeyCode.C))
            {
                sign.Corotation();
            }
            if (Input.GetKeyDown(KeyCode.I))
            {
                sign.Inversion();
            }
            if (Input.GetKeyDown(KeyCode.T))
            {
                sign.Stop();
            }
        }
    }
}