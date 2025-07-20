Shader "Custom/SprFill"
{

    Properties
    {
        [Toggle]_Clockwise("是否顺时针?", Float) = 0
        _MainColor("Color", Color) = (1, 0, 0, 1)
        _MainTex("Base (RGB) Trans (A)", 2D) = "white"{}
        _Angle("角度(%)", Range(0, 360)) = 0
    }

    SubShader
    {
        Tags {
        "RenderType" = "Opaque" "Queue" = "Transparent" }
        LOD 100

        Blend SrcAlpha OneMinusSrcAlpha

        Pass
        {
            CGPROGRAM


            #pragma vertex vert
            #pragma fragment frag

            #pragma target 2.0


            #include "UnityCG.cginc"

            half _Angle;
            fixed _Gradient;
            sampler2D _MainTex;
            float4 _MainTex_ST;
            fixed4 _MainColor;


            struct vertdata
            {
                float4 vertex : POSITION;
                float2 texcoord : TEXCOORD0;
            };
            struct v2f
            {
                float4 vertex : SV_POSITION;
                float2 texcoord : TEXCOORD0;
            };
            v2f vert(vertdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.texcoord = TRANSFORM_TEX(v.texcoord, _MainTex);
                return o;
            }


            fixed4 frag(v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.texcoord);
                half2 cuv = i.texcoord - half2(0.5, 0.5);
                half2 luv = half2(1, 0);
                half2 s = cuv.x * luv.y - luv.x * cuv.y;
                half2 c = cuv.x * luv.x + cuv.y * luv.y;
                half2 angle = 0;
                #if _CLOCKWISE_ON
                    angle = atan2(s, c) * (180 / 3.1416);
                #else
                    angle = atan2(s, -c) * (180 / 3.1416);
                #endif
                angle += step(0, cuv.y) * 360;
                clip(_Angle - angle);
                return col * _MainColor;
            }
            ENDCG
        }
    }
    Fallback Off
}
