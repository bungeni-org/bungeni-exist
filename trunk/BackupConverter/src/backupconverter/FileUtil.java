package backupconverter;

import java.io.File;

public class FileUtil
{

    /**
     * Removes this directory/file and all subfolders and files
     */
    public static boolean recursiveDelete(File dir)
    {
        if(dir.isDirectory())
        {
            String[] children = dir.list();
            for(String child : children)
            {
                boolean success = recursiveDelete(new File(dir, child));
                if (!success)
                {
                    return false;
                }
            }
        }

        // The directory is now empty so delete it
        return dir.delete();
    }
}
