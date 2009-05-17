package backupconverter;


import backupconverter.backup.Collection;
import backupconverter.backup.Item;
import backupconverter.backup.Resource;
import java.io.File;
import java.io.FileOutputStream;
import java.io.InputStream;
import java.io.IOException;
import java.io.OutputStream;

/**
 * @author Adam Retter <adam.retter@googlemail.com>
 * @version 1.0
 */
public class ANFolderWriter implements ANWriter
{
    private final Mapper mapper;
    private final File dst;

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
    public void removeCollection(Item resource) throws IOException
    {
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
