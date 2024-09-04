
root_tiff_input_path="D:/project_tem/CTransformer\ visualization\ dataset/tif_to_merge"
root_obj_output_path="D:/project_tem/CTransformer\ visualization\ dataset/obj_to_merge"
//setBatchMode(true);
//embryonames_list = newArray("Sample09", "Sample10", "Sample11", "Sample12", "Sample13", "Sample14", "Sample15");

embryonames_list = newArray("191108plc1p1","200109plc1p1");


for (idx =0;idx<embryonames_list.length;idx++){
	//setBatchMode(true);
	input_path=root_tiff_input_path+"/"+embryonames_list[idx]+"/";
	render_label_path=root_tiff_input_path+"/"+embryonames_list[idx]+"_render_indexed.txt";
	map_string = File.openAsString(render_label_path);
	map_list = split(map_string, "\n");

	thisembryoname_list = getFileList(input_path);
	write("map length "+map_list.length+"this embryo tiff length "+thisembryoname_list.length);
	for (i =0 ; i < thisembryoname_list.length; i++){
		if (endsWith(thisembryoname_list[i], ".tif")) {

			output_path=root_obj_output_path+"/"+embryonames_list[idx]+"/";
			if (!File.exists(output_path)) {
    				File.makeDirectory(output_path);
    				print("Directory created.");
			} else {
    				print(" ");
			}
			max_index=map_list[i];
			write("generating "+embryonames_list[idx]+" "+i+" "+max_index);

			action(input_path, output_path, thisembryoname_list[i], i,max_index);

			//setBatchMode(false);
    		}
		else{
			write("ERROR "+thisembryoname_list[i]);

		}
		
	}
}


function action(input_path, output_path, filename, i,max_index) {
	print("Processing: " + filename);
	name_split = split(filename, ".");
	base_name = name_split[0];
	saveing_obj_path=output_path + base_name + ".obj";
	if (File.exists(saveing_obj_path)){
		print(output_path+"  already exists");
	} else{
		open(input_path + filename);

		//run("8-bit");
		//run("RGB Color");
		//run("8-bit Color", "number=256");

		call("ij3d.ImageJ3DViewer.setCoordinateSystem", "false");
		run("Show Color Surfaces", "use=[Create New 3D Viewer] resampling=1 index=0 radius=1");
		call("ij3d.ImageJ3DViewer.select", "ImageJ 3D Viewer");

		call("ij3d.ImageJ3DViewer.select", "Smoothed image for colour index: "+max_index);
		call("ij3d.ImageJ3DViewer.exportContent", "WaveFront", saveing_obj_path);
		//call("ij3d.ImageJ3DViewer.exportContent", "STL ASCII",  output_path + base_name + ".stl");
		//call("ij3d.ImageJ3DViewer.snapshot", "512", "512");	
		//saveAs("Jpeg", output + "snap" + i + ".jpg");
		call("ij3d.ImageJ3DViewer.close");
		run("Close All");
	}
	
	}
	