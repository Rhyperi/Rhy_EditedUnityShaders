void GetBestLights( float Channel, inout int orificeType, inout float3 orificePositionTracker, inout float3 orificeNormalTracker, inout float3 penetratorPositionTracker, inout float penetratorLength ) {
	float ID = step( 0.5 , Channel );
	float baseID = ( ID * 0.02 );
	float holeID = ( baseID + 0.01 );
	float ringID = ( baseID + 0.02 );
	float normalID = ( 0.05 + ( ID * 0.01 ) );
	float penetratorID = ( 0.09 + ( ID * -0.01 ) );
	float4 orificeWorld;
	float4 orificeNormalWorld;
	float4 penetratorWorld;
	float penetratorDist=100;
	for (int i=0;i<4;i++) {
		float range = (0.005 * sqrt(1000000 - unity_4LightAtten0[i])) / sqrt(unity_4LightAtten0[i]);
		if (length(unity_LightColor[i].rgb) < 0.01) {
			if (abs(fmod(range,0.1)-holeID)<0.005) {
				orificeType=0;
				orificeWorld = float4(unity_4LightPosX0[i], unity_4LightPosY0[i], unity_4LightPosZ0[i], 1);
				orificePositionTracker = mul( unity_WorldToObject, orificeWorld ).xyz;
			}
			if (abs(fmod(range,0.1)-ringID)<0.005) {
				orificeType=1;
				orificeWorld = float4(unity_4LightPosX0[i], unity_4LightPosY0[i], unity_4LightPosZ0[i], 1);
				orificePositionTracker = mul( unity_WorldToObject, orificeWorld ).xyz;
			}
			if (abs(fmod(range,0.1)-normalID)<0.005) {
				orificeNormalWorld = float4(unity_4LightPosX0[i], unity_4LightPosY0[i], unity_4LightPosZ0[i], 1);
				orificeNormalTracker = mul( unity_WorldToObject, orificeNormalWorld ).xyz;
			}
			if (abs(fmod(range,0.1)-penetratorID)<0.005) {
				float3 tempPenetratorPositionTracker = penetratorPositionTracker;
				penetratorWorld = float4(unity_4LightPosX0[i], unity_4LightPosY0[i], unity_4LightPosZ0[i], 1);
				penetratorPositionTracker = mul( unity_WorldToObject, penetratorWorld ).xyz;
				if (length(penetratorPositionTracker)>length(tempPenetratorPositionTracker)) {
					penetratorPositionTracker = tempPenetratorPositionTracker;
				} else {
					penetratorLength=unity_LightColor[i].a;
				}
			}
		}
	}
}