void GetMainLight_float(float3 WorldPos, out float3 Color, out float3 Direction, out float DistanceAtten, out float ShadowAtten) {
#ifdef SHADERGRAPH_PREVIEW
    Direction = normalize(float3(0.5, 0.5, 0));
    Color = 1;
    DistanceAtten = 1;
    ShadowAtten = 1;
#else
    #if SHADOWS_SCREEN
        float4 clipPos = TransformWorldToClip(WorldPos);
        float4 shadowCoord = ComputeScreenPos(clipPos);
    #else
        float4 shadowCoord = TransformWorldToShadowCoord(WorldPos);
    #endif

    Light mainLight = GetMainLight(shadowCoord);
    Direction = mainLight.direction;
    Color = mainLight.color;
    DistanceAtten = mainLight.distanceAttenuation;
    ShadowAtten = mainLight.shadowAttenuation;
#endif
}

void ChooseColor_float(float3 Highlight, float3 Shadow, float Diffuse, float Threshold, out float3 OUT)
{
    if (Diffuse < Threshold)
    {
        OUT = Shadow;
    }
    else
    {
        OUT = Highlight;
    }
}

void ChooseTriColor_float(float3 Highlight, float3 Shadow, float Diffuse, float3 Midtone, float Threshold, float Threshold2, out float3 OUT)
{
    if (Diffuse < Threshold)
    {
        OUT = Shadow;
    }
    else if (Diffuse < Threshold2)
    {
        OUT = Midtone;
    }
    else
    {
        OUT = Highlight;
    }
}

void ChooseTriColorSmooth_float(float3 Highlight, float3 Shadow, float Diffuse, float3 Midtone, float Threshold, float Threshold2, float Smoothness, out float3 OUT)
{
    float smoothness = 0.1;

    float t0 = smoothstep(Threshold - smoothness, Threshold + smoothness, Diffuse);
    float3 shadowToMidtone = lerp(Shadow, Midtone, t0);

    float t1 = smoothstep(Threshold2 - smoothness, Threshold2 + smoothness, Diffuse);

    OUT = lerp(shadowToMidtone, Highlight, t1);
}

void addStripes_float(float shadowAtten, float3 Shadow, float3 Currtone, float stripes, out float3 OUT)
{
    if (shadowAtten < 0.3)
    {
        OUT = Shadow * (1 - stripes) + Currtone * stripes;
    }
    else
    {
        OUT = Currtone;
    }

}

