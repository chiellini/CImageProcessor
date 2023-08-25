
root_tiff_input_path="/Users/ysc/Desktop/3dDataset/ouput/"
root_obj_output_path="/Users/ysc/Desktop/3dDataset/obj/obj"

//
//setBatchMode(true);
embryonames_list = newArray("Sample13");




for (idx =0;idx<embryonames_list.length;idx++){
	//setBatchMode(true);
	input_path=root_tiff_input_path+embryonames_list[idx]+"/";
	render_label_path=root_tiff_input_path+embryonames_list[idx]+"_render_indexed.txt";
	map_string = File.openAsString(render_label_path);
	map_list = split(map_string, "\n");

	thisembryoname_list = getFileList(input_path);
	write("map length "+map_list.length+"this embryo tiff length "+thisembryoname_list.length);
	
	for (i =0 ; i < thisembryoname_list.length; i++){
	
		print(i,thisembryoname_list[i]);
		
	}
}


function action(input_path, output_path, filename, i,max_index) {
	print("Processing: " + filename);
	name_split = split(filename, ".");
	base_name = name_split[0];
	saveing_obj_path=output_path + base_name + ".obj";
	print("***", i, filename, "&&", base_name);

	
	
	}
	