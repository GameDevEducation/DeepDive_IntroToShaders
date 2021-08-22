Shader "Custom/DemoSurfShader"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        _Metallic ("Metallic", Range(0,1)) = 0.0
        _SnowColour ("Snow Colour", Color) = (1,1,1,1)
        _SnowStartHeight ("Snow Height", float) = 30
        _SnowFullHeight ("Snow Full Height", float) = 35
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200

        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Standard fullforwardshadows

        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 3.0

        sampler2D _MainTex;

        struct Input
        {
            float2 uv_MainTex;
            float3 worldPos;
            float3 worldNormal;
        };

        half _Glossiness;
        half _Metallic;
        fixed4 _Color;
        fixed4 _SnowColour;
        float _SnowStartHeight;
        float _SnowFullHeight;

        // Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
        // See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
        // #pragma instancing_options assumeuniformscaling
        UNITY_INSTANCING_BUFFER_START(Props)
            // put more per-instance properties here
        UNITY_INSTANCING_BUFFER_END(Props)

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            // Albedo comes from a texture tinted by color
            fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;

            //o.Albedo = c.rgb; // draws tinted texture
            //o.Albedo = fixed3(IN.uv_MainTex, IN.worldPos.y); // draw UV (Red and green channels) and Y value into blue channel
            //o.Albedo = IN.worldNormal; // colour based on the normal

            // our initial version of making snow kick in over a height range
            // if (IN.worldPos.y < _SnowStartHeight)
            //     o.Albedo = c.rgb;
            // else if (IN.worldPos.y >= _SnowFullHeight)
            //     o.Albedo = _SnowColour.rgb;
            // else
            // {
            //     half progress = (IN.worldPos.y - _SnowStartHeight) / (_SnowFullHeight - _SnowStartHeight);
            //     o.Albedo = lerp(c.rgb, _SnowColour, progress);
            // }

            // a cleaner and more efficient version for doing the snow (no branching)
            half progress = (IN.worldPos.y - _SnowStartHeight) / (_SnowFullHeight - _SnowStartHeight);
            o.Albedo = lerp(c.rgb, _SnowColour, progress);

            // use lerp and step to have objects be dark below ground
            o.Albedo = lerp(fixed3(0,0,0), o.Albedo, step(0, IN.worldPos.y));
            
            // Metallic and smoothness come from slider variables
            o.Metallic = _Metallic;
            o.Smoothness = _Glossiness;
            o.Alpha = c.a;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
