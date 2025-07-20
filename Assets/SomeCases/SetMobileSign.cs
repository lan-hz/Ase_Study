// using Cat.Logger;
using UnityEngine;
using UnityEngine.Assertions;


namespace ZWS.Equips
{
    public class SetMobileSign
    {
        public SetMobileSign(Transform tr)
        {
            Tr = tr;
            renderer = tr.GetChild(0).GetComponent<MeshRenderer>();
            Tiling = new Vector4(1, 1, 0, 0);

            var name = renderer.material.shader.name;
            Assert.AreEqual(name, "Custom/MobileSign", "获取的shader不是MobileSign，可能会出错");
        }


        // ILoger Loger = new LogManager(nameof(SetMobileSign));

        Transform Tr;
        MeshRenderer renderer;
        Vector4 Tiling;
        Color MainColor;
        Color DefaultColor;
        float Alpha = 0.5F;
        readonly int _Color = Shader.PropertyToID("_MainColor");
        readonly int _Speed = Shader.PropertyToID("_Speed");
        readonly int _Dir = Shader.PropertyToID("_Dir");
        readonly int _MainTex_ST = Shader.PropertyToID("_MainTex_ST");
        readonly MaterialPropertyBlock props = new MaterialPropertyBlock();

        //正转 反转 停
        //转动颜色（绿） ,停止颜色（灰）（正方向）（0；）

        /// <summary>
        /// 正转 顺行
        /// </summary>
        public void Corotation()
        {
            props.Clear();
            MainColor = Color.green;
            MainColor.a = Alpha;
            props.SetColor(_Color, MainColor);
            props.SetFloat(_Speed, 0.25f);
            props.SetFloat(_Dir, 1);
            props.SetVector(_MainTex_ST, Tiling);
            renderer.SetPropertyBlock(props);
        }
        /// <summary>
        /// 反转 逆行
        /// </summary>
        public void Inversion()
        {
            props.Clear();
            MainColor = Color.green;
            MainColor.a = Alpha;
            props.SetColor(_Color, MainColor);
            props.SetFloat(_Speed, 0.25f);
            props.SetFloat(_Dir, 0);
            props.SetVector(_MainTex_ST, Tiling);
            renderer.SetPropertyBlock(props);
        }
        /// <summary>
        /// 停止
        /// </summary>
        public void Stop()
        {
            SetDefault();
        }
        void SetDefault()
        {
            props.Clear();
            var color = DefaultColor == default ? Color.black : DefaultColor;
            MainColor = color;
            MainColor.a = Alpha;
            props.SetColor(_Color, MainColor);
            props.SetFloat(_Speed, 0);
            props.SetFloat(_Dir, 1);
            props.SetVector(_MainTex_ST, Tiling);
            renderer.SetPropertyBlock(props);
        }

        /// <summary>
        /// 设置MobileSign的位置 (单位:米) 缩放
        /// </summary>
        /// <param name="length">长</param>
        /// <param name="Height">高</param>
        /// <param name="Width">宽</param>       
        public void SetLocalPositionAndScale(float length, float Height, float Width)
        {
            SetLocalPosition(length, Height, Width);
            SetLocalScale(length, Height, Width);
        }

        public void SetLocalPosition(float length, float Height, float Width)
        {
            var p = Tr.localPosition;

            p.z = length * 0.5f;
            p.y = Height + 0.01f;
            p.x = 0;
            Tr.localPosition = p;
        }
        public void SetLocalScale(float length, float Height, float Width, bool Diy = false, float rate = 0.5f, float Til = 1)
        {
            var s = Tr.localScale;
            if (!Diy)
            {

                s.x = Width * 0.33f;
                s.z = length * 0.5f;
                Tr.localScale = s;
                var I = Mathf.FloorToInt(s.z);
                Tiling.y = I < Til ? Til : I;
            }
            else
            {
                s.x = Width * rate;
                s.z = length * rate;
                Tr.localScale = s;
                var I = Mathf.FloorToInt(s.z);
                Tiling.y = I < Til ? Til : I;
            }


            props.SetVector(_MainTex_ST, Tiling);
            renderer.SetPropertyBlock(props);
        }

        /// <summary>
        /// 设置MobileSign的角度
        /// </summary>
        /// <param name="x"></param>
        /// <param name="y"></param>
        /// <param name="z"></param>
        public void SetLocalEulerAngles(float x, float y, float z)
        {
            var e = Tr.localEulerAngles;
            e.x = x;
            e.y = y;
            e.z = z;
            Tr.localEulerAngles = e;
        }

        /// <summary>
        /// 设置显示的透明度（0到1之间）
        /// </summary>
        /// <param name="alpha"></param>
        public void SetOpacity(float alpha)
        {
            MainColor.a = alpha;
            Alpha = alpha;
            props.SetColor(_Color, MainColor);
            renderer.SetPropertyBlock(props);
        }
        public void SetDefaultColor(Color color)
        {
            DefaultColor = color;
        }
    }
}

