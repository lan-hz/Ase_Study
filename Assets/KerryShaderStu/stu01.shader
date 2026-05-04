Shader "Unlit/stu01"
{
    Properties
    {
       _MainTex("_MainTex",2D) = ""
    }
    SubShader
    {
     
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag       

            #include "UnityCG.cginc"

            
            sampler2D _MainTex;
            float4 _MainTex_ST;

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;             
            };


            v2f vert (appdata v)
            {
                v2f o;
                float3 pos_world =mul(unity_ObjectToWorld, v.vertex); // 模型空间转世界空间
                float3 pos_view = mul(UNITY_MATRIX_V,pos_world); // 世界空间转相机空间
                float3 pos_clip = mul(UNITY_MATRIX_P, pos_view); // 相机空间转裁剪空间
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv);
             
                return col;
            }
            ENDCG
        }
    }
}
