Shader "EdgeDissolve"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "Bump" {}
        _MaskTex("_MaskTex",2D) ="Bump"{}
        _Dissovle("Dissovle",Range(0,1.05)) = 0.5
        _AddValue("AddValue",Range(0,1)) =0.02
        [HDR]_MainColor("MainColor",color) = (1,1,1,1)

    }
    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue"="Transparent" }
        Blend SrcAlpha OneMinusSrcAlpha
        Pass
        {
            // Tags { "LightMode"="ForwardBase" }
            CGPROGRAM
            
            #pragma vertex vert
            #pragma fragment frag

            sampler2D _MainTex;
            float4  _MainTex_ST;
            sampler2D _MaskTex; 
            float4 _MaskTex_ST;
            half _Dissovle;
            half _AddValue;
            fixed4 _MainColor;
            

            struct appdata
            {
                float4 vert :POSITION;
                float2 uv :TEXCOORD;
            };
            struct v2f
            {
                float4 pos: SV_POSITION;
                float2 uv :TEXCOORD;
            };
            v2f vert(appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vert);
                o.uv = v.uv;
                return o;
            }
            fixed4 frag(v2f i):SV_TARGET
            {
                float2 uv_mainTex = i.uv * _MainTex_ST.xy + _MainTex_ST.zw;
                float2 uv_maskTex = i.uv * _MaskTex_ST.xy + _MaskTex_ST.zw;

                float4 MainTex2D = tex2D(_MainTex,uv_mainTex);
                float4 MaskTex2D =tex2D(_MaskTex, uv_maskTex);

                float AddNoise = step(_Dissovle,(MaskTex2D.r+_AddValue));
                float Noise = step(_Dissovle,MaskTex2D.r);

                float Edge = AddNoise-Noise;

                float4 EdgeColor = (MainTex2D.a * Edge * _MainColor);

                float4 BlendColors = lerp(MainTex2D,EdgeColor,Edge);
                
                float Aph = (MainTex2D.a * AddNoise);

                float4 	result = (float4((BlendColors).rgb,Aph));

                return 	result;
            }
            

            ENDCG
        }
    }
}
