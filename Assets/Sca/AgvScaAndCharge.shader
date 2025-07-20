
Shader "Unlit/AgvScaAndCharge"
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

        [Toggle]defOrCharge("是否开启原版", Range(0, 1)) = 0
        [HDR]ChargeColor("充电颜色", Color) = (0, 0, 0, 0)
        [HDR]ChargeNoiseColor("充电扰动颜色", Color) = (1, 1, 1, 1)
        _Angle("电量", Range(0, 100)) = 0
        _Ply("环宽度", Range(0, 50)) = 3.23
        _Speed("扰动速度", Range(0, 3)) = 0
        _Intens("底环透明度", Range(0, 1)) = 0
        ChargeNoise("扰动贴图", 2D) = "white" {}
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
        AlphaToMask Off
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
            sampler2D ChargeNoise;

            UNITY_INSTANCING_BUFFER_START(Props)
            float4 _MainTex_ST;
            float _Power;
            half _PaintIntensidy;
            half _NoiseSpeed;
            half _NoiseTilling;
            fixed4 _MainColor;
            fixed4 _NoiseColor;
            fixed4 _UvColor;

            half defOrCharge;
            half4 ChargeColor;
            half4 ChargeNoiseColor;
            half4 ChargeNoise_ST;
            half _Angle;
            half _Ply;
            half _Intens;
            half _Speed;

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

                half4 chargeColor = UNITY_ACCESS_INSTANCED_PROP(Props, ChargeColor);
                half4 chargeNoiseColor = UNITY_ACCESS_INSTANCED_PROP(Props, ChargeNoiseColor);
                half4 chargeNoise_ST = UNITY_ACCESS_INSTANCED_PROP(Props, ChargeNoise_ST);
                half _angle = UNITY_ACCESS_INSTANCED_PROP(Props, _Angle);
                half _ply = UNITY_ACCESS_INSTANCED_PROP(Props, _Ply);
                half _intens = UNITY_ACCESS_INSTANCED_PROP(Props, _Intens);
                half _speed = UNITY_ACCESS_INSTANCED_PROP(Props, _Speed);
                half DefOrCharge = UNITY_ACCESS_INSTANCED_PROP(Props, defOrCharge);

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

                half2 splitUv = i.uv.xy * float2(100, 100);
                half tempOutPut = step((100.0 + _angle * -1.0), splitUv.x);
                half stepSplitUv = step(splitUv.y, _ply);
                half temp_output_97_0 = ((1.0 - tempOutPut) * stepSplitUv);
                half4 temp_cast_0 = ((temp_output_97_0 * _intens)).xxxx;
                half2 uv2ChargeNoise = i.uv.xy * chargeNoise_ST.xy + chargeNoise_ST.zw;
                half2 temp_cast_2 = (uv2ChargeNoise.x).xx;
                half2 panner55 = (1.0 * _Time.y * _speed + temp_cast_2);
                half4 lerpResult = lerp(temp_cast_0, chargeNoiseColor, tex2D(ChargeNoise, panner55).r);
                fixed4 finalColor = (chargeColor * tempOutPut * stepSplitUv) + (temp_output_97_0 * lerpResult);

                return lerp(final, finalColor, DefOrCharge);
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
}
