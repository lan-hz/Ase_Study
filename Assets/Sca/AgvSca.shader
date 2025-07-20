
Shader "Unlit/AgvScan"
{
    Properties
    {
        _MainTex("网格贴图", 2D) = "white" {}
        [NoScaleOffset]_Noise("波线贴图", 2D) = "white" {}
        [NoScaleOffset]_EdgeTex("边缘光贴图", 2D) = "white" {}
        [HDR]_UvColor("背景色", Color) = (1, 1, 1, 1)
        [HDR]_MainColor("网格颜色", Color) = (1, 1, 1, 1)
        [HDR]_NoiseColor("波线颜色", Color) = (0, 0, 0, 0)
        _Power("渐变范围", Range(0, 1)) = 1
        _NoiseSpeed("波动速度", Float) = 1
        _PaintIntensidy("背景色强度", Range(0, 1)) = 0
        _NoiseTilling("波线数量", Range(0, 20)) = 1
    }

    SubShader
    {

        Tags {
        "RenderType" = "Opaque" "Queue" = "Transparent" }
        LOD 100

        CGINCLUDE
        #pragma target 3.0
        ENDCG
        Blend One One
        Cull Back
        ColorMask RGBA
        ZWrite Off


        Pass
        {

            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_instancing
            #pragma target 3.0
            #include "UnityCG.cginc"

            sampler2D _MainTex;
            sampler2D _EdgeTex;
            sampler2D _Noise;

            UNITY_INSTANCING_BUFFER_START(Props)
            float4 _MainTex_ST;
            float _Power;
            half _PaintIntensidy;
            half _NoiseSpeed;
            half _NoiseTilling;
            fixed4 _MainColor;
            fixed4 _NoiseColor;
            fixed4 _UvColor;
            UNITY_INSTANCING_BUFFER_END(Props)

            struct appdata
            {
                float4 vertex : POSITION;
                float4 color : COLOR;
                float4 uv : TEXCOORD0;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float4 uv : TEXCOORD0;
                UNITY_VERTEX_INPUT_INSTANCE_ID
                UNITY_VERTEX_OUTPUT_STEREO
            };


            v2f vert (appdata v)
            {
                v2f o;
                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
                UNITY_TRANSFER_INSTANCE_ID(v, o);

                o.uv = v.uv;
                o.vertex = UnityObjectToClipPos(v.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                UNITY_SETUP_INSTANCE_ID(i);
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);


                float4 _mainTex_ST = UNITY_ACCESS_INSTANCED_PROP(Props, _MainTex_ST);
                float _power = UNITY_ACCESS_INSTANCED_PROP(Props, _Power);
                half _paintIntensidy = UNITY_ACCESS_INSTANCED_PROP(Props, _PaintIntensidy);
                half _noiseSpeed = UNITY_ACCESS_INSTANCED_PROP(Props, _NoiseSpeed);
                half _noiseTilling = UNITY_ACCESS_INSTANCED_PROP(Props, _NoiseTilling);
                fixed4 _mainColor = UNITY_ACCESS_INSTANCED_PROP(Props, _MainColor);
                fixed4 _noiseColor = UNITY_ACCESS_INSTANCED_PROP(Props, _NoiseColor);
                fixed4 _uvColor = UNITY_ACCESS_INSTANCED_PROP(Props, _UvColor);

                float2 uv_MainTex = i.uv.xy * _mainTex_ST.xy + _mainTex_ST.zw;

                float2 uv = i.uv.xy;
                clip(0.999 - uv.y);

                float GradientIntensity = pow(uv.y, (1.0 - (-2.0 + _power * 3.0)));
                float Alpha = saturate(GradientIntensity);

                float4 MainTex = _mainColor * tex2D(_MainTex, uv_MainTex) * Alpha;


                float4 EdgeTex = tex2D(_EdgeTex, uv);
                float4 Edge = (_uvColor * EdgeTex + _paintIntensidy * 0.5) * Alpha;


                float2 panner = _Time.y * _noiseSpeed + (uv.xy * _noiseTilling);
                float4 Noise = tex2D(_Noise, panner) * Alpha * _noiseColor;

                fixed4 final = float4((MainTex + Edge + Noise).rgb, Alpha);

                return final;
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
}
