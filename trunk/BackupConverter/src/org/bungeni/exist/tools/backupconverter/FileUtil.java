package org.bungeni.exist.tools.backupconverter;

import java.io.File;

/**
 * Utilities for File operations
 *
 * @author Adam Retter <adam.retter@googlemail.com>
 * @version 1.0
 */
public class FileUtil
{

    /**
     * Removes this directory/file and all subfolders and files
     *
     * @param f The file/directory to delete
     *
     * @return true if the operation completed successfully, false otherwise
     */
    public static boolean recursiveDelete(File f)
    {
        if(f.isDirectory())
        {
            String[] children = f.list();
            for(String child : children)
            {
                boolean success = recursiveDelete(new File(f, child));
                if (!success)
                {
                    return false;
                }
            }
        }

        // The directory is now empty so delete it
        return f.delete();
    }
}