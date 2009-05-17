package backupconverter;


import backupconverter.backup.Collection;
import backupconverter.backup.Item;
import backupconverter.backup.Resource;
import backupconverter.backup.reader.BackupReader;
import java.io.File;
import java.io.FilenameFilter;
import java.io.FileOutputStream;
import java.io.InputStream;
import java.io.IOException;
import java.io.OutputStream;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * @author Adam Retter <adam.retter@googlemail.com>
 * @version 1.0
 */
public class ANFolderWriter implements ANWriter
{
    private final Mapper mapper;
    private final File dst;

    private final static Pattern yearPattern = Pattern.compile("([19|20])[0-9]{2}");
    private final static Matcher yearMatcher = yearPattern.matcher("");


    public ANFolderWriter(Mapper mapper, File dst)
    {
        this.mapper = mapper;
        this.dst = dst;
    }

    @Override
    public void writeCollection(Collection collection) throws IOException
    {
        //we dont need to do anything here in this instance,
        //all nessecary folders are created by writeResource
    }

    @Override
    public void writeResource(Resource resource) throws IOException
    {
        if(mapper.shouldMap(resource))
        {
            String anPath = mapper.mapPath(resource);

            File f = new File(dst, anPath);
            f.getParentFile().mkdirs();
            
            OutputStream os = new FileOutputStream(f);

            InputStream is = resource.getInputStream();

            int read = -1;
            byte buf[] = new byte[2048];

            while((read = is.read(buf)) > -1)
            {
                os.write(buf, 0, read);
            }

            os.close();
            is.close();
        }
    }

    @Override
    public void removeCollection(Item collection) throws IOException
    {
        if(mapper.shouldMap(collection))
        {
            String anPath = mapper.mapPath(new Collection(collection.getPath()));

            String lastSeg = anPath.substring(anPath.lastIndexOf(BackupReader.PATH_SEPARATOR)+1);
            if(lastSeg != null)
            {
                //TODO fix the yearMatcher regexp
                yearMatcher.reset(lastSeg);
                if(yearMatcher.matches())
                {
                    File container = new File(dst, anPath).getParentFile();
                    File yearFolders[] = container.listFiles(new FilenameFilter(){

                        @Override
                        public boolean accept(File dir, String name)
                        {
                            //is it a directory, does it start with the year?
                            return false;
                        }

                    });


                    for(File yearFolder : yearFolders)
                    {
                        //TODO must replace with RECURSIVE DELETE?
                        yearFolder.delete();
                    }

                    return;
                }
            }

            File f = new File(dst, anPath);
            if(!f.isDirectory() || !f.exists())
                throw new IOException("Cannot remove directory. Directory does not exist '" + f.getPath() + "'");

            //TODO must replace with RECURSIVE DELETE?
            f.delete();
        }

        throw new UnsupportedOperationException("Not supported yet.");
    }

    @Override
    public void removeResource(Item resource) throws IOException
    {
        if(mapper.shouldMap(resource))
        {
            String anPath = mapper.mapPath(new Resource(resource.getPath(), null));
            File f = new File(dst, anPath);

            if(!f.exists())
                throw new IOException("Cannot remove file. File does not exist '" + f.getPath() + "'");

            f.delete();
        }
    }
}
